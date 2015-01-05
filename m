From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] Revert "ipw2200: select CFG80211_WEXT"
Date: Mon, 05 Jan 2015 11:20:21 +0100
Message-ID: <1420453221.9459.5.camel@sipsolutions.net>
References: <1420297188.2397.3.camel@tiscali.nl>
	  <CD467A59-F563-439B-BA82-954AB27AD9CC@holtmann.org>
	  <CA+55aFzYSiUkntraMrHEhMzkt35Ft2p9E3cT7ejwQOBDwKvcOg@mail.gmail.com>
	  <1420324124.9624.60.camel@x220>
	 (sfid-20150103_232852_400842_25360CE9) <1420452301.9459.3.camel@sipsolutions.net>
	 <alpine.LNX.2.00.1501051109350.16297@pobox.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Paul Bolle <pebolle@tiscali.nl>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Marcel Holtmann <marcel@holtmann.org>,
	Stanislav Yakovlev <stas.yakovlev@gmail.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Jiri Kosina <jkosina@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1501051109350.16297@pobox.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-01-05 at 11:12 +0100, Jiri Kosina wrote:
> On Mon, 5 Jan 2015, Johannes Berg wrote:
> 
> > Well, see the big thread over there with the revert that I'm tempted to
> > not even read ...
> 
> I'd actually like to hear from you whether you share Emmanuel's point of 
> view that my revert of your patch was inappropriate; I was really 
> surprised that there might be even questions about that, given the obvious 
> userspace wreckage.

Let's not pollute this thread with that though ... :-)

I agree that the revert was the right thing to do, but from what I saw
when I briefly glimpsed at part of the thread during my vacation (and
then deciding I didn't want to deal with it then) a lot has been said in
the thread that is completely wrong. I may not care enough to correct it
though.

johannes
