From: Werner Almesberger <wa@almesberger.net>
Subject: TCP connection passing, version 8
Date: Tue, 16 Mar 2004 05:24:24 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040316052424.A26201@almesberger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, tcpcp-general@lists.sourceforge.net
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Upgrade to 2.6.4, amd64 compatibility:

http://tcpcp.sourceforge.net/tcpcp-8.tar.gz
md5sum b2aef5699ddf53e2488dabd6389d2fc3

(See http://tcpcp.sourceforge.net/ for more details.)

This is the upgrade to 2.6.4, which works not only on ia32, but
also on amd64.

The complete list of changes is below.

In the future, I'll send announcements of new versions, and such,
only to the tcpcp-general list. So if you're interested, please
subscribe to it (or hope that the archive works).

- Werner

----------------------------------- CHANGES -----------------------------------

Version 8 (16-MAR-2004)
-----------------------

- upgraded to the 2.6.4 kernel
- app/shmod.c: changed "generic value" type from "void *" to "unsigned long",
  for better 64 bit compatibility
- lib/Makefile: added -fPIC for amd64 compatibility

-- 
  _________________________________________________________________________
 / Werner Almesberger, Buenos Aires, Argentina         wa@almesberger.net /
/_http://www.almesberger.net/____________________________________________/
