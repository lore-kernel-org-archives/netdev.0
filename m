From: "Gustavo A. R. Silva" <garsilva-L1vi/lXTdts+Va1GwOuvDg@public.gmane.org>
Subject: Re: [PATCH] net: wireless: ath: ath10k: remove unnecessary code
Date: Tue, 09 May 2017 07:00:40 -0500
Message-ID: <20170509070040.Horde.6Ij5mVFBAtwRRwxv1IUZfj_@gator4166.hostgator.com>
References: <20170509042159.GA19727@embeddedgus>
 <87lgq6387s.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed; DelSp=Yes
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ath10k-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87lgq6387s.fsf-HodKDYzPHsUD5k0oWYwrnHL1okKdlPRT@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Kalle,

Quoting Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>:

> "Gustavo A. R. Silva" <garsilva-L1vi/lXTdts+Va1GwOuvDg@public.gmane.org> writes:
>
>> The name of an array used by itself will always return the array's address.
>> So these tests will always evaluate as false and therefore the _return_
>> will never be executed.
>>
>> Signed-off-by: Gustavo A. R. Silva <garsilva-L1vi/lXTdts+Va1GwOuvDg@public.gmane.org>
>
> I don't understand the commit log, especially what does "The name of an
> array used by itself" mean?
>

Let me correct that and I'll send the patch again.

Thanks!
--
Gustavo A. R. Silva
