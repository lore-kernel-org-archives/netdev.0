From: John Heffner <jheffner@psc.edu>
Subject: Re[2]: [partially solved] tcp_window_scaling degrades performance
Date: Tue, 20 Jul 2004 11:28:51 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.NEB.4.33.0407201125020.16158-100000@dexter.psc.edu>
References: <1802866788.20040720124621@dns.toxicfilms.tv>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Maciej Soltysiak <solt@dns.toxicfilms.tv>
In-Reply-To: <1802866788.20040720124621@dns.toxicfilms.tv>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

See the thread on netdev
<http://oss.sgi.com/projects/netdev/archive/2004-07/threads.html> earlier
this month under the subject "preliminary conclusions regarding window
size issues".  Your problem is most likely with a buggy window-tracking
firewall.

  -John
