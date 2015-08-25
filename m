From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCHv5 net-next 04/10] dst: Add __skb_dst_copy() variation
Date: Tue, 25 Aug 2015 20:23:46 +0200
Message-ID: <20150825182346.GI3707@pox.localdomain>
References: <1440462740-23358-1-git-send-email-joestringer@nicira.com>
 <1440462740-23358-5-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, pshelar@nicira.com,
	linux-kernel@vger.kernel.org, pablo@netfilter.org,
	fwestpha@redhat.com, hannes@redhat.com, jpettit@nicira.com,
	jesse@nicira.com, netfilter-devel@vger.kernel.org
To: Joe Stringer <joestringer@nicira.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1440462740-23358-5-git-send-email-joestringer@nicira.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/24/15 at 05:32pm, Joe Stringer wrote:
> This variation on skb_dst_copy() doesn't require two skbs.
> 
> Signed-off-by: Joe Stringer <joestringer@nicira.com>
> Acked-by: Pravin B Shelar <pshelar@nicira.com>

Acked-by: Thomas Graf <tgraf@suug.ch>
