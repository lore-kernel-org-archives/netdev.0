From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: problem with IPoA (CLIP),  NAT, and VLANS
Date: Tue, 17 Feb 2009 12:20:52 +0000
Message-ID: <20090217122052.GB6130@ff.dom.local>
References: <20090216232016.GA4803@ami.dom.local> <499AA433.8070308@hiramoto.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: Karl Hiramoto <karl@hiramoto.org>
Return-path: <netfilter-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <499AA433.8070308@hiramoto.org>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 17, 2009 at 12:49:07PM +0100, Karl Hiramoto wrote:
...
> A side note:  so far the original patch i sent works in all cases i have
> tested, but fails with tcpdump.   I suspect its because the skb gets cloned.

If there is something readable from this tcpdump, it should be helpful
to see a packet for working and non-working case during such ping
(with -nXX option).

Jarek P.
