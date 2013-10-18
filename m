From: "David Laight" <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Subject: RE: transmit lockup using smsc95xx ethernet on usb3
Date: Fri, 18 Oct 2013 16:22:02 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7397@saturn3.aculab.com>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B738B@saturn3.aculab.com> <20131017000758.GL7082@xanatos> <AE90C24D6B3A694183C094C60CF0A2F6026B7394@saturn3.aculab.com> <20131017174329.GB6256@xanatos>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Xenia Ragiadakou" <burzalodowa-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: "Sarah Sharp" <sarah.a.sharp-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-class: urn:content-classes:message
In-Reply-To: <20131017174329.GB6256@xanatos>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> It's not too hard.  Here's some directions:
> http://kernelnewbies.org/KernelBuild

I can build it easily enough but ...

Is there a .config file with a sane list of modules anywhere?
(and builtin drivers for disk boot)

The defconfig one doesn't seem to contain enough to be useful,
and the allmodconfig gives me 800MB+ to copy from the build
system to the test one (I can't seem to see an obvious way of
doing this either - apart from installing them to the 'wrong'
place on the build system and then copying everything over).

	David



--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
