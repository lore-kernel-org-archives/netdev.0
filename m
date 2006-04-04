From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [NETFILTER]: Fix fragmentation issues with bridge netfilter
Date: Tue, 04 Apr 2006 13:42:55 -0700 (PDT)
Message-ID: <20060404.134255.108672274.davem@davemloft.net>
References: <44312671.3090904@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	bdschuym@pandora.be
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: kaber@trash.net
In-Reply-To: <44312671.3090904@trash.net>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 03 Apr 2006 15:43:13 +0200

> Fix a regression from the netfilter/IPsec patches with bridging.
> Bart, please review this patch, if everything is fine I think it
> should also go in -stable.

Applied, thanks Patrick.  Please submit this to -stable.
