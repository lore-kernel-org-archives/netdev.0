From: Werner Almesberger <wa@almesberger.net>
Subject: TCP connection passing, version 5
Date: Sat, 21 Dec 2002 03:48:09 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021221034809.A17934@almesberger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

A very minor update:

http://www.almesberger.net/tcpcp/tcpcp-5.tar.gz
md5sum d30310aec5e5c22e5fbc178274cd7c46

This one mainly flushes lots of extensions for a testing framework
I've made over the last few weeks. The testing framework isn't
there yet, and the extensions aren't particularly pretty either.

The patch is now relative to 2.5.49, and there's also a patch for
UML as of 2.5.47. tcpcp on UML is fun for demos :-)

- Werner

----------------------------------- CHANGES -----------------------------------

Version 5 (21-DEC-2002)
-----------------------

- upgraded to the 2.5.49 kernel
- make "upload" now runs md5sum after uploading
- tentatively added -b ("background") option to cpshd
- added UML build process in uml/
- added framework for running programs under UML in umlrun/
- mkpatch now exits with non-zero exit status on error

-- 
  _________________________________________________________________________
 / Werner Almesberger, Buenos Aires, Argentina         wa@almesberger.net /
/_http://www.almesberger.net/____________________________________________/
