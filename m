From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2/2] IPv6: strict address checks even on globals in
 ndisc
Date: Wed, 21 Jan 2004 22:34:31 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040121223431.5929dca1.davem@redhat.com>
References: <Pine.LNX.4.58.0401141035260.23925@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ville Nuorvala <vnuorval@tcs.hut.fi>
In-Reply-To: <Pine.LNX.4.58.0401141035260.23925@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 14 Jan 2004 11:08:04 +0200 (EET)
Ville Nuorvala <vnuorval@tcs.hut.fi> wrote:

> The attached patch adds a "strict" parameter to ip6_chk_addr() and
> ip6_get_ifaddr() to allow link-local protocols like ND and DAD to do
> strict address checks even on addresses with greater scope than
> link-local.

Looks fine, applied.

Thanks Ville.
