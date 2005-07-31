From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: Re: [git patches] new wireless stuffs
Date: Sat, 30 Jul 2005 18:04:47 -0700
Message-ID: <20050731010447.GF8195@jm.kir.nu>
References: <42EC0C3E.7030705@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Netdev List <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262971AbVGaBFz@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <42EC0C3E.7030705@pobox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jul 30, 2005 at 07:24:46PM -0400, Jeff Garzik wrote:

> One big thing I'm still hoping for is that someone will merge HostAP 
> (where ieee80211 code came from) with the ieee80211 generic code.  The 
> HostAP maintainer has been unwilling to do it, even though he has been 
> good about keeping HostAP updated, so hopefully a volunteer will step up.

I would say this has been more due to lack of time than unwillingness on
my part. Finally, I got git set up yesterday and got back to working
with the wireless-2.6/netdev-2.6 code and I'm planning on working with
the Host AP and ieee80211 code merge. I would expect the client side
functionality to be relatively easy merge, but the AP side functionality
may require considerable amount of work due to the current ieee80211
code being more focused on the client side.

-- 
Jouni Malinen                                            PGP id EFC895FA
