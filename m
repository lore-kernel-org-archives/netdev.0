From: Markus Frahm <frahm@sybuca.de>
Subject: Fwd: iproute weight balancing problem with youtube
Date: Tue, 9 Dec 2008 18:03:34 +0100
Message-ID: <200812091803.35682.frahm@sybuca.de>
Reply-To: shorewall-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: shorewall-devel@lists.sourceforge.net,
 netdev@vger.kernel.org
Return-path: <shorewall-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/shorewall-devel>,
	<mailto:shorewall-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=shorewall-devel>
List-Post: <mailto:shorewall-devel@lists.sourceforge.net>
List-Help: <mailto:shorewall-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/shorewall-devel>,
	<mailto:shorewall-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: shorewall-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Hello,
I didn't receive any answer or subscription confirmation from the other list 
yet, so I forward the problem to this list. Can anybody help?
Greetings
  Markus

----------  Forwarded Message  ----------

Subject: iproute weight balacing problem with youtube
Date: Monday 27 October 2008
From: Markus Frahm <frahm@sybuca.de>
To: shemminger@osdl.org, lartc@mailman.ds9a.nl

Dear Stephen Hemminger,
we have found a problem with ip route and multiple internet connections using 
the ip route 'weight' option to balance the traffic of a NAT firewall between 
several lines. Internet sites like 'youtube' show videos only with 50% 
probability because youtube and similar sites demand several connections (for 
the web site and the flash stream) to come from the same source IP. Is there a 
simple solution for this problem for example to increase the time in the 
balancing algorithm or a cache for source IPs? 
Regards

  Markus





-------------------------------------------------------


------------------------------------------------------------------------------
SF.Net email is Sponsored by MIX09, March 18-20, 2009 in Las Vegas, Nevada.
The future of the web can't happen without you.  Join us at MIX09 to help
pave the way to the Next Web now. Learn more and register at
http://ad.doubleclick.net/clk;208669438;13503038;i?http://2009.visitmix.com/
