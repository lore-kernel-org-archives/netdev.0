From: "Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/1] iwmc3200: add more SDIO device ids
Date: Mon, 24 Aug 2009 15:29:24 -0700
Message-ID: <43e72e890908241529m3fb29676pa52a9db44029c52f@mail.gmail.com>
References: <1251149659-32212-1-git-send-email-tomas.winkler@intel.com>
	<43e72e890908241436o5f30cfe6xa7bdda8b25ac082@mail.gmail.com>
	<1ba2fa240908241520q5be2060co145ec0745954dcf0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
To: Tomas Winkler <tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1ba2fa240908241520q5be2060co145ec0745954dcf0-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 24, 2009 at 3:20 PM, Tomas Winkler<tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> On Tue, Aug 25, 2009 at 12:36 AM, Luis R. Rodriguez<mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>=
 wrote:
>> On Mon, Aug 24, 2009 at 2:34 PM, Tomas Winkler<tomas.winkler@intel.c=
om> wrote:
>>> add WiFi BGN SKU and WiMAX 2.4GHz SKU device ids
>>>
>>> Cc:inaky.perez-gonzalez-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
>>> Cc:cindy.h.kao-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
>>> Cc:yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
>>> Signed-off-by: Tomas Winkler <tomas.winkler-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
>>
>> Since it seems we are preferring to not do this for PCI for cases
>> where the ID will only be used for 1 device perhaps its best to remo=
ve
>> all those ids and stuff them directly into the intel driver itself
>> that will use it.
>>
> I don't have strong opinion about it but this is the current habit
> IIRC there was a mail thread that explicitly asked to move SDIO IDs
> there, =C2=A0of course I cannot locate it right now :(

Sure, understood, whoever maintains this should decide.

  Luis
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
