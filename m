From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6: Autoconfig link-local address on ip6-ip6 tunnel
 device
Date: Fri, 28 Nov 2003 04:07:30 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031128040730.244b76da.davem@redhat.com>
References: <Pine.LNX.4.58.0311051412180.28216@rhea.tcs.hut.fi>
	<20031125.035531.94714784.yoshfuji@linux-ipv6.org>
	<Pine.LNX.4.58.0311271147250.3257@rhea.tcs.hut.fi>
	<20031127.193910.96333709.yoshfuji@linux-ipv6.org>
	<Pine.LNX.4.58.0311281146560.9203@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ville Nuorvala <vnuorval@tcs.hut.fi>
In-Reply-To: <Pine.LNX.4.58.0311281146560.9203@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 28 Nov 2003 12:34:12 +0200 (EET)
Ville Nuorvala <vnuorval@tcs.hut.fi> wrote:

> Hi Dave, Yoshifuji-san is now ok with this patch :) Would you apply it?
> 
> Its purpose is to enable autoconfiguration of link-local addresses on
> the ip6-ip6 tunnel devices.

I will, just that I'm in no rush to do this since Linus won't look
at anything until at least next week. :)
