# == Class: oradb::database
#
#
# action        =  createDatabase|deleteDatabase
# database_type  = MULTIPURPOSE|DATA_WAREHOUSING|OLTP
#
define oradb::database(
  $oracle_base               = undef,
  $oracle_home               = undef,
  $grid_home                 = undef,  # used in script templates (${db_name}.sql)
  $version                   = '11.2', # 11.2|12.1
  $user                      = 'oracle',
  $group                     = 'dba',
  $download_dir              = '/install',
  $action                    = 'create',
  $template                  = undef,
  $template_seeded           = undef,
  $db_name                   = 'orcl',
  $db_domain                 = undef,
  $db_port                   = '1521',
  $sys_password              = 'Welcome01',
  $system_password           = 'Welcome01',
  $data_file_destination     = undef,
  $recovery_area_destination = undef,
  $character_set             = 'AL32UTF8',
  $nationalcharacter_set     = 'UTF8',
  $init_params               = undef,
  $sample_schema             = 'TRUE',
  $memory_percentage         = '40',
  $memory_total              = '800',
  $database_type             = 'MULTIPURPOSE', # MULTIPURPOSE|DATA_WAREHOUSING|OLTP
  $em_configuration          = 'NONE',  # CENTRAL|LOCAL|ALL|NONE
  $storage_type              = 'FS', #FS|CFS|ASM
  $asm_snmp_password         = 'Welcome01',
  $db_snmp_password          = 'Welcome01',
  $asm_diskgroup             = 'DATA',
  $recovery_diskgroup        = undef,
  $cluster_nodes             = undef, # comma separated list with at first the local and at second the remode host e.g. "racnode1,racnode2"
  $remote_node               = undef, # currently only used in script files
  $container_database        = false, # 12.1 feature for pluggable database
  $puppet_download_mnt_point = undef,
  $control_files                  = '(&quot;<%= @oracle_base %>/oradata/{DB_UNIQUE_NAME}/control01.ctl&quot;, &quot;<%= @data_file_destination %>/{DB_UNIQUE_NAME}/control02.ctl&quot;)',
  $audit_trail                    = 'DB',
  $db_recovery_file_dest_size_mb  = '1000',
  $spfile                         = '{ORACLE_HOME}/dbs/spfile{SID}.ora',
  $redo_logs                 = undef,
  $use_script                = false,
  $java_db_option            = true,
  $context_db_option         = true,
  $ordinst_db_option         = true,
  $interMedia_db_option      = true,
  $apex_db_option            = true,  
)
{
  if (!( $version in ['11.2','12.1'])) {
    fail('Unrecognized version')
  }

  if $action == 'create' {
    $operationType = 'createDatabase'
  } elsif $action == 'delete' {
    $operationType = 'deleteDatabase'
  } else {
    fail('Unrecognized database action')
  }

  if (!( $database_type in ['MULTIPURPOSE','DATA_WAREHOUSING','OLTP'])) {
    fail('Unrecognized database_type')
  }

  if (!( $em_configuration in ['NONE','CENTRAL','LOCAL','ALL'])) {
    fail('Unrecognized em_configuration')
  }

  if (!( $storage_type in ['FS','CFS','ASM'])) {
    fail('Unrecognized storage_type')
  }

  if ( $version == '11.2' and $container_database == true ){
    fail('container or pluggable database is not supported on version 11.2')
  }

  $execPath = '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin'

  if $puppet_download_mnt_point == undef {
    $mountPoint = 'oradb/'
  } else {
    $mountPoint = $puppet_download_mnt_point
  }

  case $::kernel {
    'Linux': {
      $userHome = "/home/${user}"
    }
    'SunOS': {
      $userHome = "/export/home/${user}"
    }
    default: {
      fail('Unrecognized operating system')
    }
  }

  if (is_hash($init_params) or is_string($init_params)) {
    if is_hash($init_params) {
      $initParamsArray = sort(join_keys_to_values($init_params, '='))
      $sanitizedInitParams = join($initParamsArray,',')
    } else {
      $sanitizedInitParams = $init_params
    }
  } else {
    fail 'init_params only supports a String or a Hash as value type'
  }

  $sanitized_title = regsubst($title, '[^a-zA-Z0-9.-]', '_', 'G')

  if $db_domain {
    $globaldb_name = "${db_name}.${db_domain}"
  } else {
    $globaldb_name = $db_name
  }

  if ! defined(File["${download_dir}/database_${sanitized_title}.rsp"]) {
    file { "${download_dir}/database_${sanitized_title}.rsp":
      ensure  => present,
      content => template("oradb/dbca_${version}.rsp.erb"),
      mode    => '0770',
      owner   => $user,
      group   => $group,
      before  => Exec["oracle database ${title}"],
    }
  }
    
  if ( $template_seeded ) {
    $templatename = "${oracle_home}/assistants/dbca/templates/${template_seeded}.dbc"
  } elsif ( $template ) {
    $templatename = "${download_dir}/${template}_${sanitized_title}.dbt"
    file { $templatename:
      ensure  => present,
      content => template("${mountPoint}/${template}.dbt.erb"),
      mode    => '0775',
      owner   => $user,
      group   => $group,
      before  => Exec["oracle database ${title}"],
    }
  } else {
    $templatename = undef
  }

  if ( $use_script == true ) {
    oradb::database_script_files { "$sanitized_title":
      oracle_base                    => $oracle_base,
      oracle_home                    => $oracle_home,
      grid_home                      => $grid_home,
      user                           => $user,
      group                          => $group,
      download_dir                   => $download_dir,
		  db_name                        => $db_name,
		  db_domain                      => $db_domain,
		  sys_password                   => $sys_password,
		  system_password                => $system_password,
		  data_file_destination          => $data_file_destination,
		  recovery_area_destination      => $recovery_area_destination,
		  character_set                  => $character_set,
		  nationalcharacter_set          => $nationalcharacter_set,
		  init_params                    => $init_params,
		  cluster_nodes                  => $cluster_nodes,
		  remote_node                    => $remote_node,
		  container_database             => $container_database, 
		  audit_trail                    => $audit_trail,
		  db_recovery_file_dest_size_mb  => $db_recovery_file_dest_size_mb,
		  redo_logs                      => $redo_logs,
		  java_db_option                 => $java_db_option,
		  context_db_option              => $context_db_option,
		  ordinst_db_option              => $ordinst_db_option,
		  interMedia_db_option           => $interMedia_db_option,
		  apex_db_option                 => $apex_db_option,
		  before                         => Exec["oracle database ${title}"],
    }
  } 

  if $action == 'create' {
    if ( $use_script == true ) {
      $command = "${download_dir}/${sanitized_title}.sh"  
    } elsif ( $templatename ) {
      if ( $version == '11.2' or $container_database == false ) {
        if ( $cluster_nodes != undef) {
          $command = "${oracle_home}/bin/dbca -silent -createDatabase -templateName ${templatename} -gdbname ${globaldb_name} -characterSet ${character_set} -responseFile NO_VALUE -sysPassword ${sys_password} -systemPassword ${system_password} -dbsnmpPassword ${db_snmp_password} -asmsnmpPassword ${asm_snmp_password} -storageType ${storage_type} -emConfiguration ${em_configuration} -nodelist ${cluster_nodes}"
        } else {
          $command = "${oracle_home}/bin/dbca -silent -createDatabase -templateName ${templatename} -gdbname ${globaldb_name} -characterSet ${character_set} -responseFile NO_VALUE -sysPassword ${sys_password} -systemPassword ${system_password} -dbsnmpPassword ${db_snmp_password} -asmsnmpPassword ${asm_snmp_password} -storageType ${storage_type} -emConfiguration ${em_configuration}"
        }
      } else {
        if( $cluster_nodes != undef) {
          $command = "${oracle_home}/bin/dbca -silent -createDatabase -templateName ${templatename} -gdbname ${globaldb_name} -characterSet ${character_set} -createAsContainerDatabase ${container_database} -responseFile NO_VALUE -sysPassword ${sys_password} -systemPassword ${system_password} -dbsnmpPassword ${db_snmp_password} -asmsnmpPassword ${asm_snmp_password} -storageType ${storage_type} -emConfiguration ${em_configuration} -nodelist ${cluster_nodes}"
        } else {
          $command = "${oracle_home}/bin/dbca -silent -createDatabase -templateName ${templatename} -gdbname ${globaldb_name} -characterSet ${character_set} -createAsContainerDatabase ${container_database} -responseFile NO_VALUE -sysPassword ${sys_password} -systemPassword ${system_password} -dbsnmpPassword ${db_snmp_password} -asmsnmpPassword ${asm_snmp_password} -storageType ${storage_type} -emConfiguration ${em_configuration}"
        }
      }
    } else {
      $command = "${oracle_home}/bin/dbca -silent -responseFile ${download_dir}/database_${sanitized_title}.rsp"
    }
    exec { "oracle database ${title}":
      command     => "$command",
      creates     => "${oracle_base}/admin/${db_name}",
      timeout     => 0,
      path        => $execPath,
      user        => $user,
      group       => $group,
      cwd         => $oracle_base,
      environment => ["USER=${user}",],
      logoutput   => true,
    }
  } elsif $action == 'delete' {
    exec { "oracle database ${title}":
      command     => "${oracle_home}/bin/dbca -silent -responseFile ${download_dir}/database_${sanitized_title}.rsp",
      onlyif      => "ls ${oracle_base}/admin/${db_name}",
      timeout     => 0,
      path        => $execPath,
      user        => $user,
      group       => $group,
      cwd         => $oracle_base,
      environment => ["USER=${user}",],
      logoutput   => true,
    }
  }
}
