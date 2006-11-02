From: "Ivan Matveich" <ivan.matveich@gmail.com>
Subject: Re: [airo.c bug] Couldn't allocate RX FID / Max tries exceeded when issueing command
Date: Thu, 2 Nov 2006 16:21:16 -0500
Message-ID: <b5def3a40611021321h22ec79c3x51a54ec7d5b07b3@mail.gmail.com>
References: <b5def3a40611011914v59ecd4c3xb6965591524aa11@mail.gmail.com>
	 <1162483971.2646.9.camel@localhost.localdomain>
	 <b5def3a40611021030s1b73daa1k2055e5f4373fa746@mail.gmail.com>
	 <1162494679.3347.8.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linville@tuxdriver.com,
	netdev@vger.kernel.org, breed@users.sourceforge.net,
	achirica@users.sourceforge.net, jt@hpl.hp.com, fabrice@bellet.info
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752331AbWKBVVT@vger.kernel.org>
To: "Dan Williams" <dcbw@redhat.com>
In-Reply-To: <1162494679.3347.8.camel@localhost.localdomain>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/2/06, Dan Williams <dcbw@redhat.com> wrote:
> Do you know which kernel version that patch first appeared in?

It was committed on 1 Dec 2005, and 2.6.15 was released on 3 Jan 2006.

> That would be a great idea, let us know what the results are, especially
> if you cna figure out which firmware version you have, or if the card
> itself is really just dead.

No luck with freebsd: error resetting card.

I'll try my luck with Cisco's Windows utility---probably
tomorrow---but I'd now wager that my card has simply croaked. (I've
even taken it out and re-seated it in its slot, just in case that
helped.) In any case, thanks for the help.
