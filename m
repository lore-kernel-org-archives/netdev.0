From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [git patches] new wireless stuffs
Date: Sun, 31 Jul 2005 12:07:36 +0100
Message-ID: <20050731110736.GA4020@infradead.org>
References: <42EC0C3E.7030705@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Netdev List <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261675AbVGaLIg@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <42EC0C3E.7030705@pobox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jul 30, 2005 at 07:24:46PM -0400, Jeff Garzik wrote:
> 
> If this is post-2.6.13 material, that's fine.
> 
> I've been getting tired of the slow movement of wireless.  A little bit 
> of that is my fault, certainly.  I've also been wanting to get these net 
> drivers out to Linux users.
> 
> This adds HostAP, ipw2100, ipw2200, and the generic ieee80211 code.  The 
> only -changes- in this set are cosmetic.

Any chance we can give the hostap driver a better name?  hostap describes
the AP mode it can operate on, but it should really be named after the hardware
it supports in some way.
