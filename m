From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch] 2.6.7-rc1 - r8169 rediff
Date: Tue, 25 May 2004 01:18:11 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040525011811.C3940@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

A set of patches against 2.6.7-rc1 which includes the NAPI changes, the
link rework issued by Andy Lutomirski and a new shiny (?) TBI handling is
available. It fixes an inverted link status bug which appeared in the serie
announced on 05/20/2004 as well.

Testers/comments welcome.

All in one patch against 2.6.7-rc1:
  http://www.fr.zoreil.com/people/francois/misc/20040525-2.6.7-rc1-r8169.c-test.patch

Individual files:
  http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.7-rc1-00

Tarball:
  http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.7-rc1-00/r8169-blob.tar.bz2

--
Ueimor
