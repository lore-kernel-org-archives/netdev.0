From: "Ky Srinivasan" <KSRINIVASAN@volera.com>
Subject: neighbor table overflow
Date: Tue, 04 Jun 2002 09:44:00 -0600
Sender: owner-netdev@oss.sgi.com
Message-ID: <scfc8bb4.069@prv-mail20.provo.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <owner-netdev@oss.sgi.com>
To: <netdev@oss.sgi.com>
Content-Disposition: inline
List-Id: netdev.vger.kernel.org

 While running  Web Polygraph benchmark against a proxy hosted on a
 Linux system 
 (kernel version: 2.4.18-0.22), we are overflowing the neighbor table
-
 line number 661 in route.c.  Is this a known problem. Any help here
 would be greatly appreciated. 

K. Y
