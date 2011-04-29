From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 0/7] ethtool: generalize use of
	ethtool_cmd_speed API
Date: Fri, 29 Apr 2011 14:12:40 -0700 (PDT)
Message-ID: <20110429.141240.233691679.davem@davemloft.net>
References: <1303954043-17440-1-git-send-email-decot@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: sgruszka@redhat.com, grundler@parisc-linux.org,
	e1000-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	eilong@broadcom.com, mirq-linux@rere.qmqm.pl,
	netdev@vger.kernel.org, bhutchings@solarflare.com
To: decot@google.com
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1303954043-17440-1-git-send-email-decot@google.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: David Decotigny <decot@google.com>
Date: Wed, 27 Apr 2011 18:27:16 -0700

> Third version of the patch series ensuring ethtool_cmd::speed/_hi
> fields are accessed using ethtool_cmd_speed/_set API. Thanks to Ben
> and Stephen for their feedbacks that have been integrated here,
> including some from Ben suggested in PATCHv1 and added here (intel GbE
> drivers: last patch in the series).

Great work David, all applied to net-next-2.6

Thanks!

------------------------------------------------------------------------------
WhatsUp Gold - Download Free Network Management Software
The most intuitive, comprehensive, and cost-effective network 
management toolset available today.  Delivers lowest initial 
acquisition cost and overall TCO of any competing solution.
http://p.sf.net/sfu/whatsupgold-sd
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
