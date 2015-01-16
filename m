From: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Subject: RE: NETDEV WATCHDOG:  internal(r8152): transmit queue 0 timed out
Date: Fri, 16 Jan 2015 09:37:56 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB2EE6935@RTITMBSV03.realtek.com.tw>
References: <m99j1v$n60$1@ger.gmane.org> <54B8CAC2.6020406@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Community support for Fedora users
	<users-TuqUDEhatI4ANWPb/1PvSmm0pvjS0E/A@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: poma <pomidorabelisima-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, nic_swsd <nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <54B8CAC2.6020406-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Content-Language: zh-TW
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

 poma [mailto:pomidorabelisima-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org] 
> Sent: Friday, January 16, 2015 4:25 PM
[...]
> > This looks like a USB problem. Is there a way to get usb (or 
> > NetworkManager) to reinitialize the driver when this happens?
> 
> I would ask these people for advice, therefore.

Our hw engineers need to analyse the behavior of the device.
However, I don't think you have such instrument to provide
the required information. If we don't know the reason, we
couldn't give you the proper solution. Besides, your solution
would work if and only if reloading the driver is helpful.

The issue have to debug from the hardware, and I have no idea
about what the software could do before analysing the hw. Maybe
you could try the following driver first to check if it is useful.

http://www.realtek.com.tw/downloads/downloadsView.aspx?Langid=2&PNid=13&PFid=56&Level=5&Conn=4&DownTypeID=3&GetDown=false
 
Best Regards,
Hayes
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
