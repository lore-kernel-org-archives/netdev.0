From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: [PATCH] Revert "ipw2200: select CFG80211_WEXT"
Date: Mon, 5 Jan 2015 11:12:57 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1501051109350.16297@pobox.suse.cz>
References: <1420297188.2397.3.camel@tiscali.nl>  <CD467A59-F563-439B-BA82-954AB27AD9CC@holtmann.org>  <CA+55aFzYSiUkntraMrHEhMzkt35Ft2p9E3cT7ejwQOBDwKvcOg@mail.gmail.com>  <1420324124.9624.60.camel@x220> (sfid-20150103_232852_400842_25360CE9)
 <1420452301.9459.3.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Paul Bolle <pebolle@tiscali.nl>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Marcel Holtmann <marcel@holtmann.org>,
	Stanislav Yakovlev <stas.yakovlev@gmail.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1420452301.9459.3.camel@sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 5 Jan 2015, Johannes Berg wrote:

> Well, see the big thread over there with the revert that I'm tempted to
> not even read ...

I'd actually like to hear from you whether you share Emmanuel's point of 
view that my revert of your patch was inappropriate; I was really 
surprised that there might be even questions about that, given the obvious 
userspace wreckage.

Again, the only thing I really care for is the compatibility layer to 
userspace. I don't question at all the fact nl80211 provides much better 
functionality and its usage definitely should be encouraged.

Thanks,

-- 
Jiri Kosina
SUSE Labs
