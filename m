From: Werner Almesberger <wa@almesberger.net>
Subject: TCP connection passing, version 7
Date: Thu, 4 Mar 2004 11:17:59 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040304111759.A22625@almesberger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, tcpcp-general@lists.sourceforge.net
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Back among the living:

http://tcpcp.sourceforge.net/tcpcp-7.tar.gz
md5sum 60a10b219ab363258d56d2f01f28edfa

tcpcp is a mechanism to pass ownership of a TCP connection endpoint
from one application to another, without the knowledge of the other
peer.

The project has been dormant for about a year, but now that I have
the suitable testing tool with umlsim, it's time to restart it.

This release updates the patch to the 2.6.3 kernel. I've also
removed all the UML-related testing infrastructure, which is now
obsolete.

The complete list of changes is below.

There's also a new Web site for the project, at
http://tcpcp.sourceforge.net/

- Werner

----------------------------------- CHANGES -----------------------------------

Version 7 (4-MAR-2004)
----------------------

- Makefile: changed upload target to SourceForge upload procedure
- removed "umlrun" subsystem
- removed UML build
- upgraded to the 2.6.3 kernel
- renamed original kernel source directory from *.orig to *-orig

-- 
  _________________________________________________________________________
 / Werner Almesberger, Buenos Aires, Argentina         wa@almesberger.net /
/_http://www.almesberger.net/____________________________________________/
