From: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
Subject: Re: [PATCH v3 1/4] MAINTAINERS: Add entry for APM X-Gene SoC ethernet driver
Date: Wed, 23 Apr 2014 17:51:38 -0700
Message-ID: <CAKh23F=Ukhufm3XMmSmaTU3AvmeoDDMeFwodgU-B_XH09sdbOQ@mail.gmail.com>
References: <1397702368-4846-1-git-send-email-isubramanian@apm.com>
	<1397702368-4846-2-git-send-email-isubramanian@apm.com>
	<1397704685.14062.14.camel@joe-AO725>
	<CABxcv=mj+phHmyg2U2jW51mLTwBN9Au791m-GtqU5BXDPy7Gtg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"jcm-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <jcm-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	patches <patches-qTEPVZfXA3Y@public.gmane.org>,
	Linux Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Keyur Chudgar <kchudgar-qTEPVZfXA3Y@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	Ravi Patel <rapatel-qTEPVZfXA3Y@public.gmane.org>
To: Javier Martinez Canillas <javier-0uQlZySMnqxg9hUCZPvPmw@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CABxcv=mj+phHmyg2U2jW51mLTwBN9Au791m-GtqU5BXDPy7Gtg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Javier,

On Sun, Apr 20, 2014 at 5:56 PM, Javier Martinez Canillas
<javier-0uQlZySMnqxg9hUCZPvPmw@public.gmane.org> wrote:
> Hello Lyappan,
>
> On Thu, Apr 17, 2014 at 5:18 AM, Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org> wrote:
>> On Wed, 2014-04-16 at 19:39 -0700, Iyappan Subramanian wrote:
>>> This patch adds a MAINTAINERS entry for APM X-Gene SoC
>>> ethernet driver.
>> []
>>> diff --git a/MAINTAINERS b/MAINTAINERS
>> []
>>> @@ -686,6 +686,14 @@ S:       Maintained
>>>  F:   drivers/net/appletalk/
>>>  F:   net/appletalk/
>>>
>>> +APPLIED MICRO (APM) X-GENE SOC ETHERNET DRIVER
>>> +M:   Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
>>> +M:   Keyur Chudgar <kchudgar-qTEPVZfXA3Y@public.gmane.org>
>>> +M:   Ravi Patel <rapatel-qTEPVZfXA3Y@public.gmane.org>
>>> +S:   Maintained
>>> +F:   drivers/net/ethernet/apm/xgene
>>
>> Please add a terminating slash to show this is a directory.
>>
>> F:      drivers/net/ethernet/apm/xgene/
>>
>
> Also if you are maintaining this driver as a part of your daily work
> (i.e: actually being paid for it by your company) the status should be
> "Supported" instead.
>
> If you are doing it on your own time but still using your company
> email address then "Maintained" is correct.

Thanks.  I will change this to Supported.

>
> Best regards,
> Javier
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
