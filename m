From: anand@eis.iisc.ernet.in (SVR Anand)
Subject: TCP advertized window
Date: Fri, 19 Jul 2002 12:28:23 +0530 (GMT+05:30)
Sender: owner-netdev@oss.sgi.com
Message-ID: <200207190658.MAA21653@eis.iisc.ernet.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <owner-netdev@oss.sgi.com>
To: netdev@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

When I did tcpdump I observed that the tcp advertised window is not fixed to
maximum value of 32K or 64K for the entire duration of the connection, but 
is evolving from some starting value at the start of the connection. The 
maximum value to which it grows is again not constant for connections to 
different hosts.

Can you let me know what is the mechanism used in computing the advertised 
window ?

Anand
