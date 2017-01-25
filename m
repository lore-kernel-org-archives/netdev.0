From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH 2/2] mac80211: use accessor functions to set sta->_flags
Date: Wed, 25 Jan 2017 10:17:39 +0100
Message-ID: <1485335859.17709.3.camel@sipsolutions.net>
References: <1485272531-11587-1-git-send-email-amadeusz.slawinski@tieto.com>
         <1485272531-11587-2-git-send-email-amadeusz.slawinski@tieto.com>
         <1485272668.1236.5.camel@sipsolutions.net>
         <CA+db6Z1OtO4_93KN-YoEaVg79zY5BgX2u0S+8FGVdkWav0iB2g@mail.gmail.com>
         (sfid-20170125_095558_832079_04D76103)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Amadeusz Slawinski <amadeusz.slawinski-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CA+db6Z1OtO4_93KN-YoEaVg79zY5BgX2u0S+8FGVdkWav0iB2g-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org> (sfid-20170125_095558_832079_04D76103)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2017-01-25 at 09:55 +0100, Amadeusz Slawinski wrote:
> And yes I did. Somehow managed to ignore those warnings though, sorry
> about that.

:)
That was intentional so nobody changing mac80211 in the future will
accidentally play with those flags through the normal accessors.

> Rechecked with just first patch and it should still be good. Please
> ignore this one ;)

Yeah, I still have that one pending, no worries :)

johannes
