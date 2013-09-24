From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: linux-next: manual merge of the ipsec-next tree with the
 net-next tree
Date: Tue, 24 Sep 2013 12:25:05 +0200
Message-ID: <20130924102505.GS7660@secunet.com>
References: <20130924121629.f818475ddf308b0494cfce2a@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Fan Du <fan.du@windriver.com>, Joe Perches <joe@perches.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130924121629.f818475ddf308b0494cfce2a@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen.

On Tue, Sep 24, 2013 at 12:16:29PM +1000, Stephen Rothwell wrote:
> Hi Steffen,
> 
> Today's linux-next merge of the ipsec-next tree got a conflict in
> include/net/xfrm.h between commit d511337a1eda ("xfrm.h: Remove extern
> from function prototypes") from the net-next tree and commit aba826958830
> ("{ipv4,xfrm}: Introduce xfrm_tunnel_notifier for xfrm tunnel mode
> callback") from the ipsec-next tree.
> 

Thanks for the information, I'll do a rebase of the ipsec-next
tree tomorrow.
