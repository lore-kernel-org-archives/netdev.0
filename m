From: Werner Almesberger <wa@almesberger.net>
Subject: Re: TCP connection passing, version 6
Date: Mon, 6 Jan 2003 09:04:39 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030106090439.A27389@almesberger.net>
References: <20021221034809.A17934@almesberger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20021221034809.A17934@almesberger.net>; from wa@almesberger.net on Sat, Dec 21, 2002 at 03:48:09AM -0300
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Another minor update:

http://www.almesberger.net/tcpcp/tcpcp-6.tar.gz
md5sum 92bfafd1a8fe253b8793b222d8f7f386

This one brings the kernel version (normal and for UML) to 2.5.54,
and also gets the testing framework a little step closer to
usefulness.

- Werner

----------------------------------- CHANGES -----------------------------------

Version 6 (6-JAN-2003)
----------------------

- upgraded to the 2.5.54 kernel for regular build and for UML
- README: clarified that connection passing is transparent to the peer
- README: clarified that "local adress" means IP address (reported by Patrick
  Schaaf)
- added references to LVS and Cisco's SLB (suggested by Patrick Schaaf)
- uml/Makefile: root_fs is now a direct make target
- umlrun: run_agent can now also run directly under run_master
- umlrun: added client IDs and session disconnect/reconnect

-- 
  _________________________________________________________________________
 / Werner Almesberger, Buenos Aires, Argentina         wa@almesberger.net /
/_http://www.almesberger.net/____________________________________________/
