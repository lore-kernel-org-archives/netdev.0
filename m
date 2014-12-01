From: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Is this 32-bit NCM?
Date: Mon, 1 Dec 2014 17:54:35 +0100 (CET)
Message-ID: <alpine.LNX.2.03.1412011753230.13971@gmail.com>
References: <alpine.LNX.2.03.1411262250160.4356@gmail.com> <87ppc957h1.fsf@nemi.mork.no> <alpine.LNX.2.03.1411271037050.9464@gmail.com> <874mtl55ar.fsf@nemi.mork.no> <CAPChA0cLuvRpYTYuFoi3bewqASgf_oZHSz5yQQ8JYm96dZ4-TQ@mail.gmail.com> <54781523.6030600@audiocodes.com>
 <alpine.LNX.2.03.1411280923230.3997@gmail.com> <54783443.50700@audiocodes.com> <alpine.LNX.2.03.1411280944200.4040@gmail.com> <54783A1D.3090607@audiocodes.com> <alpine.LNX.2.03.1411281014450.4101@gmail.com> <54783F18.1070709@audiocodes.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-857807932-1417452876=:13971"
Cc: Alex Strizhevsky <alexxst-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	=?ISO-8859-15?Q?Bj=F8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>,
	Midge Shaojun Tan <ShaojunMidge.Tan-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>,
	"youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Eli Britstein <Eli.Britstein-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>
To: Kevin Zhu <Mingying.Zhu-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <54783F18.1070709-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-857807932-1417452876=:13971
Content-Type: TEXT/PLAIN; charset=Windows-1252
Content-Transfer-Encoding: 8BIT

Evne to thank you for giving me a test device / shell, I am now modifying 
thedriver to be extra debug-ful. I don't know where exactly this will lead if 
anywhere, and really have no clue of whatto do next, since all seems normal. 
But at least I'll have a clue of what happens.


On Fri, 28 Nov 2014, Kevin Zhu wrote:

==Date: Fri, 28 Nov 2014 10:23:43
==From: Kevin Zhu <Mingying.Zhu-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>
==To: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
==Cc: Alex Strizhevsky <alexxst-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Bjørn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>,
==    Midge Shaojun  Tan <ShaojunMidge.Tan-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>,
==    "youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
==    "linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
==    "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
==    Eli Britstein <Eli.Britstein-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>
==Subject: Re: Is this 32-bit NCM?
==
==Yes. The MACs are right. When I started Wireshark, promisc mode was set.
==
==Regards,
==Kevin
==
==On 11/28/2014 05:17 PM, Enrico Mioso wrote:
==> Sorry - resending message to all.
==> Is the MAC right? In my case it was, but ... you never know.
==> And - have you tried the promisc mode, just in case... don't know if this might
==> even be implementedi n the driver, think not, but...
==> I don't know what to think anymore.
==> this ARP packet seems the same as with windows... but might be it's only my
==> impression.
==This email and any files transmitted with it are confidential material. They are intended solely for the use of the designated individual or entity to whom they are addressed. If the reader of this message is not the intended recipient, you are hereby notified that any dissemination, use, distribution or copying of this communication is strictly prohibited and may be unlawful.
==
==If you have received this email in error please immediately notify the sender and delete or destroy any copy of this message
==
--8323328-857807932-1417452876=:13971--
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
