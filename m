From: "Nikita N." <nikitan@operamail.com>
Subject: Re: brcmsmac: TX power blocked in BCM4313
Date: Tue, 17 Feb 2015 01:03:34 -0800
Message-ID: <1424163814.3140549.228461101.1C2E5AB1@webmail.messagingengine.com>
References: <1424007136.2042747.227726249.45B6A0E2@webmail.messagingengine.com>
 <1424094835.3188168.228077393.0E2006F5@webmail.messagingengine.com>
 <54E2107F.4000709@broadcom.com>
 <1424112787.3303548.228201005.68F1D224@webmail.messagingengine.com>
 <54E24B48.80601@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: hauke@hauke-m.de, brcm80211-dev-list@broadcom.com,
	linux-wireless@vger.kernel.org, Kalle Valo <kvalo@codeaurora.org>,
	Pat Erley <pat-lkml@erley.org>, brudley@broadcom.com,
	Franky Lin <frankyl@broadcom.com>, meuleman@broadcom.com,
	linville@tuxdriver.com, pieterpg@broadcom.com, hdegoede@redhat.com,
	wens@csie.org, netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Arend van Spriel <arend@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54E24B48.80601@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Arend,
 
> brcmsmac does assure tx power is within regulatory limits by enforcing a 
> world regulatory domain. So what is not supported is modifying tx power 
> settings through user-space.

Yes, I believe that could be right, *a* world regulatory domain looks
indeed enforced, the USA one only, which is pre-set default inside
EEPROM registries device, isn't it?
 
> I know, but that driver is not fully open-source as it links in a binary 
> blob.

AFAIK, also brcmsmac needs at least 2 firmware files to operate, without
those nothing works.
Isn't it the same concept?
 
> I totally lost track of this one. I am using brcmsmac in monitor mode 
> using bcm43224 which captures 11n frames just fine. I will give it a try 
> with a bcm4313. The assoc response in your capture shows undefined MCS 
> set so maybe there really are no 11n MCS rates used (?).

If that was a suggestion about to purchase a bcm43224 or any other
Broadcom Corp. product, isn't really convincing, seen the overall
support quality Customers are experiencing in here...
About my capture file, in the case it was really incomplete someone
could have informed me at least a year ago.
But anyway no respectable QA Testing team needs a purchasing Customer to
help in verifying such enormous issue, isn't it? 
 
> Our team consist of two man working full-time on the upstream linux 
> drivers. So our "customer care" is something that we try to deal with on 
> the side and admittedly things slip between the cracks.

Really, *TWO* men? Are you kidding? Is that how much Broadcom Corp.
values the Linux community?
Needles to remind, even if Linux users don't pay for the OS license as
Windows do, they do pay allright for any Broadcom hardware they
purchase!
Internet startups which sell a button on internet, they have Dev and QA
team 5 times bigger than that!
I sense a very gross capacity and resource planning competence issue in
here.
I kindly ask you, please forward that mail to your higher Managers, on
my personal behalf, Thanks.

-- 
http://www.fastmail.com - Same, same, but different...
