From: Adrian Chadd <adrian-h+KGxgPPiopAfugRpC6u6w@public.gmane.org>
Subject: Re: [PATCH v3] mac80211: Support on-channel scan option.
Date: Mon, 16 Apr 2012 11:03:33 -0700
Message-ID: <CAJ-VmokfxVEekHSuKP4KxgAGbK6S8z_vuOOYb=W3cERMmHvdKQ@mail.gmail.com>
References: <1334248689-23018-1-git-send-email-greearb@candelatech.com>
	<4F8C57CC.4090505@sipsolutions.net>
	<4F8C59B2.20207@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4F8C59B2.20207-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 16 April 2012 10:41, Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org> wrote:

> I also tried some manual scans on a fixed frequency. =A0Those
> appeared to work, though I got scan results for APs on different
> channels. =A0Does that seem right? =A0I can't see how my patch
> would affect that sort of thing one way or another...

You'll see off-channel beacons in 11bg mode. :-)

It's actually rather helpful, except that the RSSI reported isn't
anywhere near as valid as you'd like.



Adrian
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
