# == Class: oradb::database_script_files
#
# creates bash and sql files for database creation
#
define oradb::database_script_files(
  $oracle_base                    = undef,
  $oracle_home                    = undef,
  $grid_home                      = undef,
  $user                           = undef,
  $group                          = undef,
  $download_dir                   = undef,
  $db_name                        = undef,
  $db_domain                      = undef,
  $sys_password                   = undef,
  $system_password                = undef,
  $data_file_destination          = undef,
  $recovery_area_destination      = undef,
  $character_set                  = undef,
  $nationalcharacter_set          = undef,
  $init_params                    = undef,
  $cluster_nodes                  = undef,
  $remote_node                    = undef,
  $container_database             = undef, 
  $audit_trail                    = undef,
  $db_recovery_file_dest_size_mb  = undef,
  $java_db_option                 = undef,
  $context_db_option              = undef,
  $ordinst_db_option              = undef,
  $interMedia_db_option           = undef,
  $apex_db_option                 = undef, 
) {
  
  # only tested with oracle 12c
    file { "${download_dir}/${title}.sql":
      ensure  => present,
      content => template("${module_name}/scripts/db_name.sql.erb"),
      mode    => '0775',
      owner   => $user,
      group   => $group,
      before  => Exec["oracle database ${title}"],
    }
    
    file { "${download_dir}/${title}.sh":
      ensure  => present,
      content => template("${module_name}/scripts/db_name.sh.erb"),
      mode    => '0775',
      owner   => $user,
      group   => $group,
      before  => Exec["oracle database ${title}"],
    }
    
    file { "${download_dir}/CreateDB_${title}.sql":
      ensure  => present,
      content => template("${module_name}/scripts/CreateDB.sql.erb"),
      mode    => '0775',
      owner   => $user,
      group   => $group,
      before  => Exec["oracle database ${title}"],
    }
    
    file { "${download_dir}/CreateDBCatalog_${title}.sql":
      ensure  => present,
      content => template("${module_name}/scripts/CreateDBCatalog.sql.erb"),
      mode    => '0775',
      owner   => $user,
      group   => $group,
      before  => Exec["oracle database ${title}"],
    }
    
    file { "${download_dir}/CreateDBFiles_${title}.sql":
      ensure  => present,
      content => template("${module_name}/scripts/CreateDBFiles.sql.erb"),
      mode    => '0775',
      owner   => $user,
      group   => $group,
      before  => Exec["oracle database ${title}"],
    }

    file { "${download_dir}/init_${title}.ora":
      ensure  => present,
      content => template("${module_name}/scripts/init.ora.erb"),
      mode    => '0775',
      owner   => $user,
      group   => $group,
      before  => Exec["oracle database ${title}"],
    }
    
    file { "${download_dir}/lockAccount_${title}.sql":
      ensure  => present,
      content => template("${module_name}/scripts/lockAccount.sql.erb"),
      mode    => '0775',
      owner   => $user,
      group   => $group,
      before  => Exec["oracle database ${title}"],
    }
    
    file { "${download_dir}/postDBCreation_${title}.sql":
      ensure  => present,
      content => template("${module_name}/scripts/postDBCreation.sql.erb"),
      mode    => '0775',
      owner   => $user,
      group   => $group,
      before  => Exec["oracle database ${title}"],
    }
        
    if ( $cluster_nodes != undef) {
      file { "${download_dir}/CreateClustDBViews_${title}.sql":
        ensure  => present,
        content => template("${module_name}/scripts/CreateClustDBViews.sql.erb"),
        mode    => '0775',
        owner   => $user,
        group   => $group,
        before  => Exec["oracle database ${title}"],
      } 
    }
    
    if ( $apex_db_option == true) {
      file { "${download_dir}/apex_${title}.sql":
        ensure  => present,
        content => template("${module_name}/scripts/apex.sql.erb"),
        mode    => '0775',
        owner   => $user,
        group   => $group,
        before  => Exec["oracle database ${title}"],
      } 
    }
    
    if ( $context_db_option == true) {
      file { "${download_dir}/context_${title}.sql":
        ensure  => present,
        content => template("${module_name}/scripts/context.sql.erb"),
        mode    => '0775',
        owner   => $user,
        group   => $group,
        before  => Exec["oracle database ${title}"],
      } 
    } 
    
    if ( $java_db_option == true) {
      file { "${download_dir}/JServer_${title}.sql":
        ensure  => present,
        content => template("${module_name}/scripts/JServer.sql.erb"),
        mode    => '0775',
        owner   => $user,
        group   => $group,
        before  => Exec["oracle database ${title}"],
      } 
    }
    
    if ( $interMedia_db_option == true) {
      file { "${download_dir}/interMedia_${title}.sql":
        ensure  => present,
        content => template("${module_name}/scripts/interMedia.sql.erb"),
        mode    => '0775',
        owner   => $user,
        group   => $group,
        before  => Exec["oracle database ${title}"],
      } 
    }
    
    if ( $ordinst_db_option == true) {
      file { "${download_dir}/ordinst_${title}.sql":
        ensure  => present,
        content => template("${module_name}/scripts/ordinst.sql.erb"),
        mode    => '0775',
        owner   => $user,
        group   => $group,
        before  => Exec["oracle database ${title}"],
      } 
    }   
  
}