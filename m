From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6: Protect proxied addresses against DAD
Date: Wed, 20 Aug 2003 11:24:14 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030820112414.6fcb4ee5.davem@redhat.com>
References: <Pine.LNX.4.44.0308201423500.541-200000@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: usagi-core@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ville Nuorvala <vnuorval@tcs.hut.fi>
In-Reply-To: <Pine.LNX.4.44.0308201423500.541-200000@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 20 Aug 2003 14:40:14 +0300 (EEST)
Ville Nuorvala <vnuorval@tcs.hut.fi> wrote:

> a proxy has to reply to DAD probes, otherwise it can't protect its
> addresses. The attached patch fixes this, please apply!

Patch applied, thanks.
