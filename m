From: Michael Renzmann <netdev@nospam.otaku42.de>
Subject: Re: Broadcom 43xx first results
Date: Tue, 06 Dec 2005 08:17:58 +0100
Message-ID: <1133853478.4468.9.camel@gimli>
References: <E1Eiyw4-0003Ab-FW@www1.emo.freenet-rz.de>
	 <20051205190038.04b7b7c1@griffin.suse.cz> <1133806444.4498.35.camel@gimli>
	 <43948B13.2090509@pobox.com>
Reply-To: netdev@nospam.otaku42.de
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@nospam.otaku42.de, Jiri Benc <jbenc@suse.cz>,
	mbuesch@freenet.de, linux-kernel@vger.kernel.org,
	bcm43xx-dev@lists.berlios.de, NetDev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750727AbVLFH3K@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <43948B13.2090509@pobox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi.

On Mon, 2005-12-05 at 13:46 -0500, Jeff Garzik wrote:
> > Although I'm a bit biased towards MadWifi, I'd second your suggestion to
> > make use of the Devicescape code. The benefit of having a fully-blown
> > 802.11 stack in the kernel that drivers can make use of has been
> > discussed before, so I won't go into that yet again.
> Use the stack that's already in the kernel.

Sorry, that was my bad. I thought that the Devicescape code found its
way to the kernel (didn't follow the discussion some months ago too
closely). Although I think there probably are better alternatives to the
802.11 stack that is in the kernel right now, having a central 802.11
stack at all is a great improvement that should be used where possible.

> Encouraging otherwise hinders continued wireless progress under Linux.

That depends. If the encouraging is about an alternative, more complete
and superior 802.11 stack for Linux which could be integrated with less
effort than extending the existing code, that should be worth to talk
about. 

Please note that I'm not refering here to any of the related suggestions
which have been made during the past months - it's a general statement.

Bye, Mike
