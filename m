From: "Gianluca" <gianluca@linux.it>
Subject: IPv6 route buffer space problem
Date: Fri, 19 Nov 2004 19:10:47 +0100
Message-ID: <20041119175924.M79505@coredumps.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=iso-8859-1
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi, i have a problem when i add more than 500/540 sit interfaces on my linux 
box (debian), if i add a new interface (with iptunnel and ifconfig) i 
haven't errors but when i add a new router for the interface i have this 
error "No buffer space available".
I had search on /proc for increment the buffer but i dont have found 
anythink, i think that i need to modify the kernel sources.
Please help me.

Gianluca.
