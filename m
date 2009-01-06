From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: [PATCH 2/3] ieee1394: remove unneeded last_rx
Date: Wed, 07 Jan 2009 00:22:58 +0100
Message-ID: <4963E7D2.3080205@s5r6.in-berlin.de>
References: <20090106145456.37ecedaa@extreme> <20090106145554.53ef1ccc@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: krh@redhat.com, netdev@vger.kernel.org,
	linux1394-devel@lists.sourceforge.net, David Miller <davem@davemloft.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux1394-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20090106145554.53ef1ccc@extreme>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux1394-devel>
List-Post: <mailto:linux1394-devel@lists.sourceforge.net>
List-Help: <mailto:linux1394-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: linux1394-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Last_rx is now done if needed inside bonding.

Just in case that this is meant to go through net(dev?)-2.6.git rather
than linux1394-2.6.git:
Acked-by: Stefan Richter <stefanr@s5r6.in-berlin.de>
-- 
Stefan Richter
-=====-==--= ---= --===
http://arcgraph.de/sr/

------------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It is the best place to buy or sell services for
just about anything Open Source.
http://p.sf.net/sfu/Xq1LFB
