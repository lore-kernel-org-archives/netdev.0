From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: Re: [PATCH 2.6] Intersil Prism54 wireless driver
Date: Wed, 10 Mar 2004 19:17:09 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040311031709.GC3782@jm.kir.nu>
References: <20040304023524.GA19453@bougret.hpl.hp.com> <20040310165548.A24693@infradead.org> <20040310172114.GA8867@bougret.hpl.hp.com> <404F5097.4040406@pobox.com> <20040310175200.GA9531@bougret.hpl.hp.com> <404F5744.1040201@pobox.com> <20040311024816.GC3738@jm.kir.nu> <404FD6BC.7090409@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jt@hpl.hp.com, Christoph Hellwig <hch@infradead.org>,
        "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
        Linux kernel mailing list <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <404FD6BC.7090409@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Mar 10, 2004 at 10:02:20PM -0500, Jeff Garzik wrote:

> How about submitting a patch, when the CryptoAPI and backcompat cleanups 
> are complete?  I will apply to the wireless-2.6 tree, and we can start 
> working on the kernel's overall 802.11 support from there.

OK, I'll do the cleanups in the Host AP CVS and submit the patch after
that. I'll make a new branch for this cleanup, so the changes will be
available there if people are interested in commenting the code before
the cleanup is complete.

-- 
Jouni Malinen                                            PGP id EFC895FA
