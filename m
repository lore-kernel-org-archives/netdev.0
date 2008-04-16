From: Paulius Zaleckas <paulius.zaleckas-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>
Subject: Re: [RFC] Patch to option HSO driver to the kernel
Date: Wed, 16 Apr 2008 15:12:06 +0300
Message-ID: <4805ED16.3080104@teltonika.lt>
References: <20080414213238.GB28833@kroah.com> <4805C469.7050408@teltonika.lt> <4805E8E1.3090200@teltonika.lt> <200804161403.20955.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200804161403.20955.oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Oliver Neukum wrote:
> Am Mittwoch, 16. April 2008 13:54:09 schrieb Paulius Zaleckas:
> 
>> Incremental patch. Converted ethtool ioctl to ethtool_ops.
> 
> You were faster. We need to coordinate. Which changes are you doing now?
> 

Actually I am tuning my newly added hso_get_drvinfo...
Instead of writing to tmp buffer to write directly to fw_version.

Should I post incremental patch or replacement?

I always get crash when closing serial terminal application. I will
post dump in couple minutes.

Paulius

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
