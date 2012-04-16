From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH v3] mac80211: Support on-channel scan option.
Date: Mon, 16 Apr 2012 12:58:53 -0700
Message-ID: <4F8C79FD.7030701@sipsolutions.net>
References: <1334248689-23018-1-git-send-email-greearb@candelatech.com> (sfid-20120412_183929_638765_C70D881D) <4F8C57CC.4090505@sipsolutions.net> <4F8C59B2.20207@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4F8C59B2.20207-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 4/16/2012 10:41 AM, Ben Greear wrote:
>>> + if ((req->channels[0]->flags&
>>> + IEEE80211_CHAN_PASSIVE_SCAN) ||
>>> + !local->scan_req->n_ssids) {
>>
>> That formatting is a bit off it seems. Or is that just my mailer?
>
> Well, it looked OK to me..though when I replied my mailer
> certainly made it look funky. I'll re-run it through checkpatch
> just in case.

It just seemed the & should have a space in front, and it could be on a 
single line with the constant? Anyway, I'm using thunderbird right now 
and don't know what kind of messes it makes.

johannes
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
