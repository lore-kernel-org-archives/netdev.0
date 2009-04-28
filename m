From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH] : CDC EEM driver patch to be applied to 2.6.30 kernel
Date: Tue, 28 Apr 2009 02:55:19 -0700
Message-ID: <200904280255.19964.david-b@pacbell.net>
References: <3a98b4410904270912g1838b534j2b53561b8caa1543@mail.gmail.com> <20090428.023149.111899398.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: omar.oberthur@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp115.sbc.mail.sp1.yahoo.com ([69.147.64.88]:23203 "HELO
	smtp115.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751750AbZD1KCB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2009 06:02:01 -0400
In-Reply-To: <20090428.023149.111899398.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 28 April 2009, David Miller wrote:
> From: Omar Laazimani <omar.oberthur@gmail.com>
> Date: Mon, 27 Apr 2009 18:12:03 +0200
> 
> > This is version 3 of the patch that introduces a CDC EEM kernel module
> > (host side only) to supports USB EEM devices.
> > 
> > Signed-off-by: Omar Laazimani <omar.oberthur@gmail.com>
> 
> David, does it look good to you?

He's addressed most of the issues I raised; maybe all,
I've only had a quick glance at this version.


> And, assuming it's OK, do you want 
> to take this or would you like me too?
> 
> Either way is fine with me.

If it's OK by me, I'll either ack it or send you a
new patch with my s-o-by.  Hold off a couple days.

(Since this one goes through the drivers/net queue, I think
it should merge through you ... I just want to sanity check
the USB-ishness, since I'm supposed to maintain the usbnet
parts of drivers/net/usb, and this is a new part of that.)

- dave
