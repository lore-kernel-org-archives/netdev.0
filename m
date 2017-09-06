From: Sebastian Gottschall <s.gottschall-t37Kgv3TaIPQT0dZR+AlfA@public.gmane.org>
Subject: Re: hung task in mac80211
Date: Wed, 6 Sep 2017 15:08:42 +0200
Message-ID: <6b08a34a-1c0e-452e-0e37-f721800f2a04@dd-wrt.com>
References: <CAGnkfhwi9MmtLneeU23iWEGLj9cb1ODb3KzzOqTDvA6nNVsugg@mail.gmail.com>
 <20170906144019.1c98a636@elisabeth>
 <1504702115.13457.16.camel@sipsolutions.net>
 <1504702990.13457.19.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
        Stefano Brivio <sbrivio-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Matteo Croce <mcroce-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1504702990.13457.19.camel-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am 06.09.2017 um 15:03 schrieb Johannes Berg:
> On Wed, 2017-09-06 at 14:48 +0200, Johannes Berg wrote:
>> I'm surprised nobody saw this before - though perhaps Sebastian's
>> useless report is the same.
> Oh, that's because this is only for the offloaded manager thing, and
> that's only ath10k.
>
> johannes
that explans the behaviour i have found with latest mac80211 and ath10k.


-- 
Mit freundlichen Grüssen / Regards

Sebastian Gottschall / CTO

NewMedia-NET GmbH - DD-WRT
Firmensitz:  Berliner Ring 101, 64625 Bensheim
Registergericht: Amtsgericht Darmstadt, HRB 25473
Geschäftsführer: Peter Steinhäuser, Christian Scheele
http://www.dd-wrt.com
email: s.gottschall-t37Kgv3TaIPQT0dZR+AlfA@public.gmane.org
Tel.: +496251-582650 / Fax: +496251-5826565
