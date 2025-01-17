#!/bin/sh
#Copyright (c) 2020 Divested Computing Group
#
#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <https://www.gnu.org/licenses/>.

# set restrictive umask
if [ "$(/usr/bin/id -ru)" -ge 1000 ] && [ "$(/usr/bin/id -u)" -ge 1000 ] && [ "$(/usr/bin/id -gn)" = "$(/usr/bin/id -un)" ]; then
    umask 0077;
else
    umask 0022;
fi;
