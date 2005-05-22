From: raz ben jehuda <razb@bitband.com>
Subject: user space checksum
Date: Sun, 22 May 2005 09:51:48 +0300
Message-ID: <1116744708.3021.12.camel@raz-laptop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I do not know if this was ever suggested.so i'll try any way.
Why not give the user the chance to supply the kernel/card with the
checksums instead of having the kernel/network card do the work ? 
This is because a user is aware to the data he sends and he can optimize
the data checksum calculations more than anyone else. for instance a web
server sends its html pages, which are static data. it can pre-calculate
the checksums.

Anyone ? 
-- 
Raz
Long Live The Penguin
