From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: conntrack: initialize net.ct.generation
Date: Mon, 14 Apr 2014 10:38:43 +0200
Message-ID: <20140414083843.GA4553@localhost>
References: <1397237660-30632-1-git-send-email-avagin@openvz.org>
 <20140412.165818.1540640354445899640.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: avagin@openvz.org, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org, brouer@redhat.com,
	kaber@trash.net, kadlec@blackhole.kfki.hu
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140412.165818.1540640354445899640.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Apr 12, 2014 at 04:58:18PM -0400, David Miller wrote:
> From: Andrey Vagin <avagin@openvz.org>
> Date: Fri, 11 Apr 2014 21:34:20 +0400
> 
> > [  251.920788] INFO: trying to register non-static key.
> 
> I'll let Pablo integrate this.

Applied, thanks.
