From: Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>
Subject: Fw: Build failure on linux-next master branch
Date: Tue, 25 Aug 2009 09:37:07 +1000
Message-ID: <20090825093707.13bf8c49.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="Multipart=_Tue__25_Aug_2009_09_37_07_+1000_8rYbYM1E+HdKOMrO"
Cc: linux-next-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

--Multipart=_Tue__25_Aug_2009_09_37_07_+1000_8rYbYM1E+HdKOMrO
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

[Let try a few folks who might know]

Begin forwarded message:

Date: Mon, 24 Aug 2009 12:00:24 -0400 (EDT)
From: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
To: Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>
Cc: linux-next-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Subject: Build failure on linux-next master branch



With latest next master branch I got this failure in my build system.

  Building modules, stage 2.
Kernel: arch/x86/boot/bzImage is ready  (#1801)
  MODPOST 96 modules
ERROR: "crc16" [net/bluetooth/l2cap.ko] undefined!
make[1]: *** [__modpost] Error 1


Config attached.

-- Steve



-- 
Cheers,
Stephen Rothwell                    sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org
http://www.canb.auug.org.au/~sfr/

--Multipart=_Tue__25_Aug_2009_09_37_07_+1000_8rYbYM1E+HdKOMrO
Content-Type: APPLICATION/octet-stream;
 name="config.gz"
Content-Disposition: attachment;
 filename="config.gz"
Content-Transfer-Encoding: base64

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

--Multipart=_Tue__25_Aug_2009_09_37_07_+1000_8rYbYM1E+HdKOMrO--
