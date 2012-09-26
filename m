From: Alexey ORISHKO <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
Subject: RE: removing the timer from cdc-ncm
Date: Wed, 26 Sep 2012 11:49:48 +0200
Message-ID: <2AC7D4AD8BA1C640B4C60C61C8E520154A8BED5F14@EXDCVYMBSTM006.EQ1STM.local>
References: <6020948.EvS2esPpc0@linux-lqwf.site>
 <2AC7D4AD8BA1C640B4C60C61C8E520154A8BED59B5@EXDCVYMBSTM006.EQ1STM.local>
 <9022066.PsM0uBqIB8@linux-lqwf.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "bjorn-yOkvZcmFvRU@public.gmane.org" <bjorn-yOkvZcmFvRU@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <9022066.PsM0uBqIB8-ugxBuEnWX9yG/4A2pS7c2Q@public.gmane.org>
Content-Language: en-US
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Oliver Neukum [mailto:oneukum-l3A5Bk7waGM@public.gmane.org]
 
> Thank you. Worse than I hoped, but not unexpected. I'll stare at the
> code a bit.

Just a small clarification: on Ellisys trace I see only
ConnectionSpeedChange and NetworkConnection (Connected). No data was
sent on the bulk pipe before it crashed.

/alexey
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
