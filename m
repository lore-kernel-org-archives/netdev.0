From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: [airo.c bug] Couldn't allocate RX FID / Max tries exceeded when issueing command
Date: Thu, 2 Nov 2006 13:26:28 -0800
Message-ID: <20061102212628.GA6235@bougret.hpl.hp.com>
References: <b5def3a40611011914v59ecd4c3xb6965591524aa11@mail.gmail.com> <1162483971.2646.9.camel@localhost.localdomain> <b5def3a40611021030s1b73daa1k2055e5f4373fa746@mail.gmail.com> <1162494679.3347.8.camel@localhost.localdomain> <b5def3a40611021321h22ec79c3x51a54ec7d5b07b3@mail.gmail.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Williams <dcbw@redhat.com>, linux-kernel@vger.kernel.org,
	linville@tuxdriver.com, netdev@vger.kernel.org,
	breed@users.sourceforge.net, achirica@users.sourceforge.net,
	fabrice@bellet.info
Return-path: <netdev-owner@vger.kernel.org>
Received: from madara.hpl.hp.com ([192.6.19.124]:31212 "EHLO madara.hpl.hp.com")
	by vger.kernel.org with ESMTP id S1752628AbWKBV1R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2006 16:27:17 -0500
To: Ivan Matveich <ivan.matveich@gmail.com>
Content-Disposition: inline
In-Reply-To: <b5def3a40611021321h22ec79c3x51a54ec7d5b07b3@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 02, 2006 at 04:21:16PM -0500, Ivan Matveich wrote:
> On 11/2/06, Dan Williams <dcbw@redhat.com> wrote:
> >Do you know which kernel version that patch first appeared in?
> 
> It was committed on 1 Dec 2005, and 2.6.15 was released on 3 Jan 2006.
> 
> >That would be a great idea, let us know what the results are, especially
> >if you cna figure out which firmware version you have, or if the card
> >itself is really just dead.
> 
> No luck with freebsd: error resetting card.
> 
> I'll try my luck with Cisco's Windows utility---probably
> tomorrow---but I'd now wager that my card has simply croaked. (I've
> even taken it out and re-seated it in its slot, just in case that
> helped.) In any case, thanks for the help.

	Just remembered... Check the IRQ allocation. I remmeber having
issues with the BIOS not doing the right stuff.

	Jean

