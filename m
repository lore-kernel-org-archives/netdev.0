From: "Brad House" <brad_mssw@gentoo.org>
Subject: [PATCH 2.6.0-test9-bk6] r8169.c update for 8110S support from RTL 1.6 version
Date: Sun, 16 Nov 2003 23:08:09 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <47973.68.105.173.45.1069042089.squirrel@mail.mainstreetsoftworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The current in-kernel version of the r8169 driver is v1.2
from RealTek.  This is a patch against 2.6.0-test9-bk6
and later kernels that updates the driver to 1.6 from RealTek.
Just small patches applied to it to port to 2.6 kernel, etc.
It works with the 8110S chip found on many motherboards,
especially x86_64 mobos.

http://dev.gentoo.org/~brad_mssw/kernel_patches/2.6.0/genpatches-0.4/200_r8169-8110S-111203.patch

Please CC me on any replies as I am not subscribed to the list.

-Brad House
brad_mssw@gentoo.org
