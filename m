From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 01/10] doc: update driver TX
	algorithm in timestamping.txt
Date: Fri, 14 Mar 2014 22:12:34 +0300
Message-ID: <532354A2.6000603@cogentembedded.com>
References: <1394818481-7652-1-git-send-email-kubakici@wp.pl>
	<1394818481-7652-2-git-send-email-kubakici@wp.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org
To: Jakub Kicinski <kubakici@wp.pl>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1394818481-7652-2-git-send-email-kubakici@wp.pl>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Hello.

On 03/14/2014 08:34 PM, Jakub Kicinski wrote:

> Since cd4d8fdad1f1 dev_hard_start_xmit() will not provide

    Please also specify that commit's summary line in parens.

> software timestamps. It's a responsibility of the drivers
> to call skb_tx_timestamp() at the right time.

> Cc: linux-doc@vger.kernel.org
> Signed-off-by: Jakub Kicinski <kubakici@wp.pl>

WBR, Sergei


------------------------------------------------------------------------------
Learn Graph Databases - Download FREE O'Reilly Book
"Graph Databases" is the definitive new guide to graph databases and their
applications. Written by three acclaimed leaders in the field,
this first edition is now available. Download your free book today!
http://p.sf.net/sfu/13534_NeoTech
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
