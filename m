From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH Resubmission] drivers/net/usb: Add new driver ipheth
Date: Tue, 13 Apr 2010 14:29:30 -0700 (PDT)
Message-ID: <20100413.142930.34014646.davem@davemloft.net>
References: <1270678281-20750-1-git-send-email-agimenez@sysvalve.es>
	<20100413.011540.115903049.davem@davemloft.net>
	<4BC4BFFD.9040802@sysvalve.es>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, dgiagio@gmail.com, dborca@yahoo.com,
	gregkh@suse.de, jonas.sjoquist@ericsson.com,
	steve.glendinning@smsc.com, torgny.johansson@gmail.com,
	dbrownell@users.sourceforge.net, omar.oberthur@gmail.com,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: agimenez@sysvalve.es
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4BC4BFFD.9040802@sysvalve.es>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "L. Alberto Gim=E9nez" <agimenez@sysvalve.es>
Date: Tue, 13 Apr 2010 21:03:25 +0200

> Thanks for the info. I didn't know that I had to add an entry on the
> upper level Makefile. I guess that something like
> obj-$(CONFIG_USB_IPHETH) +=3D usb/ should be enough? (I got it from t=
he
> other USB net drivers).

Yes.
