From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH 3/3] usbnet: handle remote wakeup asap
Date: Mon, 18 Jun 2012 09:55:16 +0800
Message-ID: <CACVXFVN6B70=7AE8_JmOmRBZQgAdqjsr4-WoaXb0Acadsmw0+A@mail.gmail.com>
References: <1339561217-18151-1-git-send-email-ming.lei@canonical.com>
	<1339561217-18151-4-git-send-email-ming.lei@canonical.com>
	<CACVXFVMO0Z23kW59YRyfbVFu77vG6_yAMxAhOXk619V0dhF7Fw@mail.gmail.com>
	<20120617.162233.868029041800646826.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, oneukum-l3A5Bk7waGM@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120617.162233.868029041800646826.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 18, 2012 at 7:22 AM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
> From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> Date: Fri, 15 Jun 2012 10:22:16 +0800
>
>> David, sorry, the 'GFP_ATOMIC' above should be 'flags', so could
>> you take the fixed version from attachment? Or could you do it by
>> your self?
>
> You are rushing this patch submission if you are finding such
> errors right after you post the patch.
>
> Take your time and properly audit your work, then resubmit your
> entire series again once it is really ready.

Good suggestion, I will check the patches again and test them further.

Thanks,
--
Ming Lei
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
