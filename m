From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH v1 00/11] usbnet: usb_control_msg cleanup
Date: Tue, 23 Oct 2012 17:19:29 +0800
Message-ID: <CACVXFVMDWbqOONcQvs6XARecUW=A-RnQb4QuX0CBr7zf+cNtTA@mail.gmail.com>
References: <1349959169-9432-1-git-send-email-ming.lei@canonical.com>
	<5690496.KbQ6sjjSnW@linux-lqwf.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5690496.KbQ6sjjSnW-ugxBuEnWX9yG/4A2pS7c2Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 15, 2012 at 2:30 PM, Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org> wrote:
>>
>> v1:
>>       - drop previous patch 12, and let net/core handle
>>       runtime PM in ioctl path
>
> Acked-by: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>

David, could you queue the patchset on net-next since my some usbnet
runtime PM patches depend on it?

Thanks,
--
Ming Lei
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
