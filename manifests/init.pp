# == Class: ubuntucommon
#
# Common Ubuntu configuration.
#
# === Parameters
#
# [*distcodename*]
#   Ubuntu version codename (eg: "xenial"). Should be lower-case. Defaults to
#   value of $::os['lsb']['distcodename'] from Facter. Requires
#   stringify_facts = false.
#
# [*repos*]
#   Repos to use with the release, updates, backports, and security sources.
#   This defaults to 'main universe restricted multiverse' (all available
#   repos).
#
# [*ubuntu_archive_location*]
#   URL for the location of the Ubuntu package archive. Should contain releases
#   for ${distcodename}, ${distcodename}-updates, and
#   ${distcodename}-backports and the repos in $repos. Defaults to
#   'http://us.archive.ubuntu.com/ubuntu'.
#
# [*ubuntu_security_location*]
#   URL for the location of the Ubuntu security archive. Should contain
#   releases for ${distcodename}-security and the repos in $repos. Defaults to
#   'http://security.ubuntu.com/ubuntu'.
#
# [*canonical_partners_location*]
#   URL for the location of the Canonical Partners repo. Should contain
#   releases for $distcodename and the 'partner' repo. Defaults to
#   'http://archive.canonical.com/ubuntu'.
#
# [*include_release*]
#   Whether to include the Ubuntu release repository source containing all
#   packages available with the distribution release. Uses the
#   $ubuntu_archive_location for the repo location. Defaults to true.
#
# [*include_updates*]
#   Whether to include the Ubuntu updates repository source containing all major
#   bugfixes to packages available after the distribution release. Uses the
#   $ubuntu_archive_location for the repo location. Defaults to true.
#
# [*include_backports*]
#   Whether to include the Ubuntu backports repository source containing some
#   updated packages available from a future distribution release. Uses the
#   $ubuntu_archive_location for the repo location. Defaults to true.
#
# [*include_security*]
#   Whether to include the Ubuntu security repository source containing
#   packages patched for critical security vulnerabilities after release. Uses
#   the $ubuntu_security_location for the repo location. Defaults to true.
#
# [*include_partners*]
#   Whether to include the Canonical Partners repository source containing
#   proprietary vendor packages. Uses the $canonical_partners_location for the
#   repo location. Defaults to true.
#
# [*include_sources*]
#   Whether to include the source packages for the repositories. Defaults to
#   false.
#
# === Examples
#
#  class { 'ubuntucommon':
#    distcodename => 'xenial',
#  }
#
# === Authors
#
#  Bryan Wyatt <brwyatt@gmail.com>
#
# === Copyright
#
# Copyright 2016 Bryan Wyatt, unless otherwise noted.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
class ubuntucommon (
  $distcodename                 = $::os['lsb']['distcodename'],
  $repos                        = 'main universe restricted multiverse',
  $ubuntu_archive_location      = 'http://us.archive.ubuntu.com/ubuntu/',
  $ubuntu_security_location     = 'http://security.ubuntu.com/ubuntu',
  $canonical_partners_location  = 'http://archive.canonical.com/ubuntu',
  $include_release              = true,
  $include_updates              = true,
  $include_backports            = true,
  $include_security             = true,
  $include_partners             = true,
  $include_sources              = false,
){

  if $::os['name'] != 'Ubuntu' {
    fail('This module is only supported on Ubuntu')
  }

  validate_string($distcodename)
  validate_string($repos)
  validate_string($ubuntu_archive_location)
  validate_string($ubuntu_security_location)
  validate_string($canonical_partners_location)

  validate_bool($include_release)
  validate_bool($include_updates)
  validate_bool($include_backports)
  validate_bool($include_security)
  validate_bool($include_partners)
  validate_bool($include_sources)

  class { 'apt':
    purge  => {
      'sources.list'   => true,
      'sources.list.d' => true,
      'preferences'    => true,
      'preferences.d'  => true,
    },
    update => {
      frequency => 'daily',
    },
  }

  if $include_release {
    apt::source { 'ubuntu_release':
      location => $ubuntu_archive_location,
      release  => $distcodename,
      repos    => $repos,
      include  => {
        'src' => $include_sources,
      },
    }
  }
  if $include_updates {
    apt::source { 'ubuntu_updates':
      location => $ubuntu_archive_location,
      release  => "${distcodename}-updates",
      repos    => $repos,
      include  => {
        'src' => $include_sources,
      },
    }
  }
  if $include_backports {
    apt::source { 'ubuntu_backports':
      location => $ubuntu_archive_location,
      release  => "${distcodename}-backports",
      repos    => $repos,
      include  => {
        'src' => $include_sources,
      },
    }
  }
  if $include_security {
    apt::source { 'ubuntu_security':
      location => $ubuntu_security_location,
      release  => "${distcodename}-security",
      repos    => $repos,
      include  => {
        'src' => $include_sources,
      },
    }
  }
  if $include_partners {
    apt::source { 'ubuntu_partners':
      location => $canonical_partners_location,
      release  => $distcodename,
      repos    => 'partner',
      include  => {
        'src' => $include_sources,
      },
    }
  }

  Apt::Source <| |> ~> Exec['apt_update']
  Exec['apt_update'] -> Package <| |>
}
