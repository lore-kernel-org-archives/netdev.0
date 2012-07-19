From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2] ipvs: fixed sparse warning
Date: Thu, 19 Jul 2012 10:43:42 +0900
Message-ID: <20120719014341.GI29894@verge.net.au>
References: <1342602622-2728-1-git-send-email-claudiu.ghioc@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org,
	wensong@linux-vs.org, ja@ssi.bg, pablo@netfilter.org,
	kaber@trash.net, claudiu.ghioc@gmail.com, daniel.baluta@gmail.com
To: Claudiu Ghioc <claudiughioc@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1342602622-2728-1-git-send-email-claudiu.ghioc@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 18, 2012 at 12:10:22PM +0300, Claudiu Ghioc wrote:
> Removed the following sparse warnings, wether CONFIG_SYSCTL
> is defined or not:
> *       warning: symbol 'ip_vs_control_net_init_sysctl' was not
> 	declared. Should it be static?
> *       warning: symbol 'ip_vs_control_net_cleanup_sysctl' was
> 	not declared. Should it be static?
> 
> Signed-off-by: Claudiu Ghioc <claudiu.ghioc@gmail.com>

Thanks, I have queued this up for 3.6.
