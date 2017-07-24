From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] net: Convert to using %pOF instead of full_name
Date: Mon, 24 Jul 2017 13:41:44 -0700 (PDT)
Message-ID: <20170724.134144.562191102829366953.davem@davemloft.net>
References: <20170718214339.7774-39-robh@kernel.org>
        <20170718.145146.1983238254018568174.davem@davemloft.net>
        <CAL_JsqJbEq0_yQ-T8-SGTQbRRxHs-MMCuBrK6d8_2jGQ_-7QkA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        andrew-g2DYL2Zd6BY@public.gmane.org, vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org,
        f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, madalin.bucur-3arQi8VN3Tc@public.gmane.org,
        dougmill-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, grygorii.strashko-l0cyMroinI0@public.gmane.org,
        michal.simek-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org, soren.brinkmann-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAL_JsqJbEq0_yQ-T8-SGTQbRRxHs-MMCuBrK6d8_2jGQ_-7QkA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Date: Wed, 19 Jul 2017 10:09:13 -0500

> On Tue, Jul 18, 2017 at 4:51 PM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
>> From: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
>> Date: Tue, 18 Jul 2017 16:43:19 -0500
>>
>>> Now that we have a custom printf format specifier, convert users of
>>> full_name to use %pOF instead. This is preparation to remove storing
>>> of the full path string for each node.
>>>
>>> Signed-off-by: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
>>
>> Acked-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> 
> The dependency went into 4.13. You can take this thru netdev.

Ok, applied to net-next.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
