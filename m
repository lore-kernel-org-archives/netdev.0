From: "Tomas Winkler" <tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2008-08-26
Date: Thu, 28 Aug 2008 10:59:20 +0300
Message-ID: <1ba2fa240808280059i24d2ee56rd7a3c37150e1c03c@mail.gmail.com>
References: <20080827013009.GA15781@tuxdriver.com>
	 <1ba2fa240808271226i95a7789k481a68b09dc60164@mail.gmail.com>
	 <200808272225.10557.mb@bu3sch.de>
	 <1ba2fa240808271611v382631ecn2a24e2816562d434@mail.gmail.com>
	 <20080827233103.GE5927@tesla>
	 <1ba2fa240808271719o2a3617e7re0499670de785b2f@mail.gmail.com>
	 <43e72e890808271830k6e0a9e65j790ee1e0d6d52d36@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Michael Buesch" <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Bruno Randolf" <bruno-L9ZBdB2wSWtl57MIdRCFDg@public.gmane.org>
To: "Luis R. Rodriguez" <lrodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <43e72e890808271830k6e0a9e65j790ee1e0d6d52d36-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 28, 2008 at 4:30 AM, Luis R. Rodriguez
<lrodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org> wrote:
> On Wed, Aug 27, 2008 at 5:19 PM, Tomas Winkler <tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>> This patch is marked as W/A and should have
>> probably some cleaner solution in 2.6.28
>
> OK
>
>>>> Last solution would be to remove this merging all together
>>>
>>> Absolutely not! IBSS merge is per spec, otherwise you don't really have
>>> a real IBSS.
>>
>> I'm all for following spec and we've tried really hard to make it work.
>> Anyhow I'm not sure what you call real IBSS. nobody has checked it for
>> 1.5 year this patch  is in and now is suddenly so important...
>
> I don't care about your work around, I was replying due to your insane
> comments about considering removing IBSS merge support because your
> hardware does not support it well.

Insane?!, watch your language mister I will catch you on next year OLS
:) This is definitely
not any highlighted proposal in my message

>> I would like to see if there is any  HW under mac80211 that actually
>> work with this.
>
> Atheros hardware supports IBSS merge, please consider a proper work
> around instead for hardware which does not support this.

So how do set TSF from the beacon, I'm asking because there is
currently no interface from mac80211 to driver do that.
Thanks
Tomas
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
