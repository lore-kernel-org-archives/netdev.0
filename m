From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6] Intersil Prism54 wireless driver
Date: Wed, 10 Mar 2004 22:02:20 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <404FD6BC.7090409@pobox.com>
References: <20040304023524.GA19453@bougret.hpl.hp.com> <20040310165548.A24693@infradead.org> <20040310172114.GA8867@bougret.hpl.hp.com> <404F5097.4040406@pobox.com> <20040310175200.GA9531@bougret.hpl.hp.com> <404F5744.1040201@pobox.com> <20040311024816.GC3738@jm.kir.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jt@hpl.hp.com, Christoph Hellwig <hch@infradead.org>,
        "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
        Linux kernel mailing list <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jouni Malinen <jkmaline@cc.hut.fi>
In-Reply-To: <20040311024816.GC3738@jm.kir.nu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jouni Malinen wrote:
> I'm going to be at the IEEE 802.11 meeting for the next week which is
> probably going to take more or less all of my time, but I should be able
> to allocate more time after that. If people are interested in reviewing
> the current Host AP code from the viewpoint of what would need to happen
> before it can be merged into the kernel tree, the latest version is
> available as a snapshot from my CVS tree (pserver or tarball) at
> http://hostap.epitest.fi/. The current version is almost 20k lines, so
> there is certainly quite a bit of code to review. I hope to get this to
> about 15k lines, though, with the crypto API and backwards
> compatibility cleanup.

How about submitting a patch, when the CryptoAPI and backcompat cleanups 
are complete?  I will apply to the wireless-2.6 tree, and we can start 
working on the kernel's overall 802.11 support from there.  I don't 
pretend to be an 802.11 expert, so I'll let you and Jean and other 
developers drive that end of things.  I'm mainly interested in keeping 
the API simple and clean, and maintainable.

	Jeff
