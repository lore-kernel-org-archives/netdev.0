From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v1 00/11] usbnet: usb_control_msg cleanup
Date: Tue, 23 Oct 2012 13:05:59 -0400 (EDT)
Message-ID: <20121023.130559.477102863250187178.davem@davemloft.net>
References: <1349959169-9432-1-git-send-email-ming.lei@canonical.com>
	<5690496.KbQ6sjjSnW@linux-lqwf.site>
	<CACVXFVMDWbqOONcQvs6XARecUW=A-RnQb4QuX0CBr7zf+cNtTA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oneukum-l3A5Bk7waGM@public.gmane.org
To: ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CACVXFVMDWbqOONcQvs6XARecUW=A-RnQb4QuX0CBr7zf+cNtTA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Date: Tue, 23 Oct 2012 17:19:29 +0800

> On Mon, Oct 15, 2012 at 2:30 PM, Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org> wrote:
>>>
>>> v1:
>>>       - drop previous patch 12, and let net/core handle
>>>       runtime PM in ioctl path
>>
>> Acked-by: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
> 
> David, could you queue the patchset on net-next since my some usbnet
> runtime PM patches depend on it?

Please repost it to netdev.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
