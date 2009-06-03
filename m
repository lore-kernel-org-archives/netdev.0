From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Subject: Re: net-next-2.6: Bluetooth: NULL pointer dereference in
 tty_register_device
Date: Wed, 03 Jun 2009 21:32:28 +0200
Message-ID: <1244057548.4145.13.camel@localhost.localdomain>
References: <4A26AEF2.2000900@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Oliver Hartkopp <oliver-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4A26AEF2.2000900-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Oliver,

> this morning i got this NULL pointer dereference at boot time
> with Daves (that time) latest net-next-2.6 tree.
> 
> Any idea about this bug?
> 
> I only got this problem once so far.

I have never seen it before. Could be a problem with changes inside the
TTY layer.

Regards

Marcel
