From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NETFILTER]: Fix fragmentation issues with bridge netfilter
Date: Wed, 05 Apr 2006 11:31:12 +0200
Message-ID: <44338E60.60704@trash.net>
References: <44312671.3090904@trash.net>
	<20060404.134255.108672274.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	bdschuym@pandora.be
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060404.134255.108672274.davem@davemloft.net>
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

David S. Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Mon, 03 Apr 2006 15:43:13 +0200
> 
> 
>>Fix a regression from the netfilter/IPsec patches with bridging.
>>Bart, please review this patch, if everything is fine I think it
>>should also go in -stable.
> 
> 
> Applied, thanks Patrick.  Please submit this to -stable.

Done.
