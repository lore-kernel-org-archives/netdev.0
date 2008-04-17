From: "Chetty, Jay" <jay.chetty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: RE:  Re: [RFC] Patch to option HSO driver to the kernel
Date: Thu, 17 Apr 2008 15:31:16 -0700
Message-ID: <5C56D7CF618CC543BE306900D901FB68043D1803@orsmsx414.amr.corp.intel.com>
References: <20080414213238.GB28833@kroah.com> <200804161543.23584.oliver@neukum.org> <48060536.60005@teltonika.lt> <200804171632.12972.oliver@neukum.org> A<4807C56F.5060804@teltonika.lt>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Paulius Zaleckas" <paulius.zaleckas-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>,
	<linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-class: urn:content-classes:message
In-Reply-To: A<4807C56F.5060804-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

read Documentation/usb/power-management.txt 

-----Original Message-----
From: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
[mailto:linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org] On Behalf Of Paulius Zaleckas
Sent: Thursday, April 17, 2008 2:47 PM
To: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Subject: Re: [RFC] Patch to option HSO driver to the kernel

Oliver Neukum wrote:
> can you test this one as well. The method used to determine whether
> a device is asleep is racy. This introduces a private test.

Stupid question :) How to test it? How can I force it to suspend?
I have never used any suspend on my PC :)

Paulius

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
