From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: Re: [PATCH] convert ip6_tunnel to per-cpu data
Date: Sun, 31 Aug 2003 15:14:46 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0308311506080.24254-100000@rhea.tcs.hut.fi>
References: <20030831031556.6d8ee0e8.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Christoph Hellwig <hch@lst.de>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030831031556.6d8ee0e8.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 31 Aug 2003, David S. Miller wrote:

> On Sun, 31 Aug 2003 12:06:21 +0200
> Christoph Hellwig <hch@lst.de> wrote:
>
> > Code looks like copy & pasted from icmpv6 :)
>
> Hold on this one, we're in the process of killing
> the sockets from this code.

Yes, I've been running socketless tunnels for a couple of days now and
everything seems to work all right. I'll send the patch shortly...


Ville
--
Ville Nuorvala
Research Assistant, Institute of Digital Communications,
Helsinki University of Technology
email: vnuorval@tcs.hut.fi, phone: +358 (0)9 451 5257
