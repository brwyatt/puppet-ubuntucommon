# == Class: ubuntucommon::desktop
#
# Common Ubuntu configuration for desktop versions.
#
# === Parameters
#
# [*disable_guest*]
#   Whether the lightdm guest user session should be disabled. Defaults to true.
#
# === Examples
#
#  class { 'ubuntucommon::desktop':
#    disable_guest = true,
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
class ubuntucommon::desktop (
  $disable_guest = true,
){
  include ubuntucommon

  if $disable_guest {
    file { '/etc/lightdm/lightdm.conf.d':
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
    }
    file { '/etc/lightdm/lightdm.conf.d/50-no-guest.conf':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      content => join([
        '[SeatDefaults]',
        'allow-guest=false',
        '', 
      ], "\n"),
    }
  }
}
