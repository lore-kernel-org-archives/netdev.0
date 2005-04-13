From: Daniel Drake <dsd@gentoo.org>
Subject: Problem with skge 0.6
Date: Wed, 13 Apr 2005 17:26:36 +0100
Message-ID: <425D483C.4000505@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

Gentoo have included the new skge driver in the latest install media due to a
few requests. A problem has turned up, which was also experienced in older
versions of the sk98lin driver. Any chance you could take a look?

http://bugs.gentoo.org/show_bug.cgi?id=87822

This is with Linux 2.6.11 patched with
http://dev.gentoo.org/~dsd/gentoo-sources/release-11.09/dist/4100_skge-0.6.patch
and dmesg+lspci output is included on the bug:

http://bugs.gentoo.org/87822

Thanks,
Daniel
