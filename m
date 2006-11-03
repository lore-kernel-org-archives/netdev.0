From: Benjamin Reed <br33d@yahoo.com>
Subject: Re: [airo.c bug] Couldn't allocate RX FID / Max tries exceeded when issueing command
Date: Fri, 3 Nov 2006 09:08:06 -0800 (PST)
Message-ID: <20061103170806.60233.qmail@web51511.mail.yahoo.com>
References: <b5def3a40611021321h22ec79c3x51a54ec7d5b07b3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linux-kernel@vger.kernel.org, linville@tuxdriver.com,
	netdev@vger.kernel.org, breed@users.sourceforge.net,
	achirica@users.sourceforge.net, jt@hpl.hp.com, fabrice@bellet.info
Return-path: <netdev-owner@vger.kernel.org>
Received: from web51511.mail.yahoo.com ([206.190.39.157]:1707 "HELO
	web51511.mail.yahoo.com") by vger.kernel.org with SMTP
	id S1753380AbWKCRII (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Nov 2006 12:08:08 -0500
To: Ivan Matveich <ivan.matveich@gmail.com>,
	Dan Williams <dcbw@redhat.com>
In-Reply-To: <b5def3a40611021321h22ec79c3x51a54ec7d5b07b3@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

You might find this thread useful if it is just a case
of messed up firmware:
http://sourceforge.net/mailarchive/message.php?msg_id=2970511

The gist of it is that sometimes DOS utilities work
when all else fails.

ben

--- Ivan Matveich <ivan.matveich@gmail.com> wrote:

> On 11/2/06, Dan Williams <dcbw@redhat.com> wrote:
> > Do you know which kernel version that patch first
> appeared in?
> 
> It was committed on 1 Dec 2005, and 2.6.15 was
> released on 3 Jan 2006.
> 
> > That would be a great idea, let us know what the
> results are, especially
> > if you cna figure out which firmware version you
> have, or if the card
> > itself is really just dead.
> 
> No luck with freebsd: error resetting card.
> 
> I'll try my luck with Cisco's Windows
> utility---probably
> tomorrow---but I'd now wager that my card has simply
> croaked. (I've
> even taken it out and re-seated it in its slot, just
> in case that
> helped.) In any case, thanks for the help.
> 

