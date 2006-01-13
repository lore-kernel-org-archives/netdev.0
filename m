From: "John W. Linville" <linville@tuxdriver.com>
Subject: wireless: recap of current issues (intro)
Date: Fri, 13 Jan 2006 16:26:08 -0500
Message-ID: <20060113212605.GD16166@tuxdriver.com>
References: <20060113195723.GB16166@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Jiri Benc <jbenc@suse.cz>,
	Stefan Rompf <stefan@loplof.de>,
	Mike Kershaw <dragorn@kismetwireless.net>,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Robert Hancock <hancockr@shaw.ca>,
	Alistair John Strachan <s0348365@sms.ed.ac.uk>,
	Dominik Brodowski <linux@dominikbrodowski.net>,
	Denis Vlasenko <vda@ilport.com.ua>,
	Danny van Dyk <kugelfang@gentoo.org>,
	Stephen Hemminger <shemminger@osdl.org>, feyd <feyd@nmskb.cz>,
	Chase Venters <chase.venters@clientec.com>,
	Andreas Mohr <andim2@users.sourceforge.net>,
	Bas Vermeulen <bvermeul@blackstar.nl>,
	Jean Tourrilhes <jt@hpl.hp.com>, Daniel Drake <dsd@gentoo.org>,
	Ulrich Kunitz <kune@deine-taler.de>,
	Phil Dibowitz <phil@ipom.com>,
	Simon Kelley <simon@thekelleys.org.uk>,
	Michael Buesch <mbuesch@freenet.de>,
	Marcel Holtmann <marcel@holtmann.org>,
	Patrick McHardy <kaber@trash.net>,
	Ingo Oeser <netdev@axxeo.de>,
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1422991AbWAMVhs@vger.kernel.org>
To: netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20060113195723.GB16166@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

My original post got eaten by the lists -- probably too big...

I'm reposting in sections.  After this intro follow sections on
Configuration, Compatibility, Stack, Other Issues, and Actions.
Enjoy! :-)

---

WiFi-ers...

Here I am, still feeling "up to the challenge"...  I have stopped
hyper-ventilating and the nervous vomiting is all over... :-)

Having accepted the wireless role, I wanted to review the discussions
prompted by Jeff's "State of the Union" message from a little over a
week ago.  There is lots of good talent involved in these discussions,
and I believe a surprisingly high level of agreement (some of it
nearly violent!) amongst the players.

Below I have recapped what I saw as most of the important issues.
I have endorsed some of the ideas, mostly those which seem to have
broad agreement.  I have also thrown-out a few ideas of my own.
Please do comment on all of them, as neither my summaries nor my
original ideas are likely to be without fault. :-)

I have primarily grouped the issues into configuration, compatibility,
and stack concerns.  I also included an "other" group for a few other
concerns that I though were worth mentioning.

Finally, I have included an "actions" section to reveal some of my
near-term plans and some of what I am thinking about beyond that.
I would love to hear any comments you might have on these items
as well.

Thanks for taking the time to look this over.  Creating this recap
has reinforced one thing: this is far too big for just a single person
(or even a small group) to tackle alone!

Thanks,

John
-- 
John W. Linville
linville@tuxdriver.com
