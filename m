From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Ethtool offload patch
Date: Thu, 6 Jan 2005 22:44:53 -0800
Message-ID: <20050106224453.3420f987.davem@davemloft.net>
References: <1104396895.5845.1.camel@ori.thedillows.org>
	<20050104094423.2d404759.davem@davemloft.net>
	<1104865471.9860.16.camel@dillow.idleaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Dave Dillow <dave@thedillows.org>
In-Reply-To: <1104865471.9860.16.camel@dillow.idleaire.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 04 Jan 2005 14:04:31 -0500
Dave Dillow <dave@thedillows.org> wrote:

> I know you just got back from vacation, so when you get a chance, I'd
> welcome comments on the patch series -- I did most of it simply, just to
> see how it would perform. There is (obviously) still work to do -- I
> need to figure out how to determine if an IPv6 address is local, and it
> may be nice to have some sort of LRU list to offload the most active SAs
> when resources get low on the card.

I intend to review this next week some time.  Sorry for the delay,
but it's snowing like crazy in the mountains and I simply can't
resist taking advantage of that :-)
