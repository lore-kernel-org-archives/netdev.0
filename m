From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCH v2 2/3] mwifiex: move .get_tx_power logic to station ioctl file
Date: Wed, 22 Jun 2016 09:17:13 +0300
Message-ID: <87vb11iw7q.fsf@purkki.adurom.net>
References: <1465232558-31678-1-git-send-email-javier@osg.samsung.com>
	<1465232558-31678-3-git-send-email-javier@osg.samsung.com>
	<87wplxdsln.fsf@kamboji.qca.qualcomm.com>
	<12ccd90e-e3eb-ecac-b23f-8124b0db32ad@osg.samsung.com>
	<2b5e5833ecc74a2b9cd822e8455cd0af@SC-EXCH04.marvell.com>
	<8dc6e64a-3429-4bed-e5c9-da6880eb9505@osg.samsung.com>
	<87shwkes65.fsf@kamboji.qca.qualcomm.com>
	<aeeb25f2-3253-0931-1e84-edc4590208b3@osg.samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Amitkumar Karwar <akarwar-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
	"linux-kernel\@vger.kernel.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Julian Calaby <julian.calaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Shengzhen Li <szli-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
	Enric Balletbo i Serra <enric.balletbo-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>,
	"netdev\@vger.kernel.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-wireless\@vger.kernel.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Nishant Sarmukadam <nishants-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>
To: Javier Martinez Canillas <javier-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <aeeb25f2-3253-0931-1e84-edc4590208b3-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org> (Javier
	Martinez Canillas's message of "Tue, 21 Jun 2016 10:47:01 -0400")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Javier Martinez Canillas <javier-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org> writes:

>>> Patch 3/3 applies cleanly even after dropping patch 2/3.
>>> Is that Ok for you or do you want me to re-resend a v3
>>> with only patches 1/3 and 3/3?
>> 
>> I can drop patch 2, no need to resend. Thanks.
>> 
>
> I saw that you sent your pull request for v4.8 but the
> patches from this series were not included:
>
> https://lkml.org/lkml/2016/6/21/400

I had forgotten to change the state of patches 1 and 3 from 'Changes
Requested' back to 'New' and that's why I missed them. I did that now so
they are back in my queue:

https://patchwork.kernel.org/patch/9158855/
https://patchwork.kernel.org/patch/9158851/

Thanks for checking.

-- 
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
