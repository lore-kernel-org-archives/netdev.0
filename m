From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH 02/02]usbnet & cdc-ether: Autosuspend for online devices
Date: Thu, 03 Dec 2009 22:27:16 +0100
Message-ID: <1259875636.3041.3.camel@violet>
References: <200912032210.55403.oliver@neukum.org>
	 <20091203.131930.42454846.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: oliver@neukum.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:44825 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753291AbZLCV1S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 16:27:18 -0500
In-Reply-To: <20091203.131930.42454846.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Oliver,

> > commit 17b97d1c24a061843a8f707e80f23a7b0b7647df
> > Author: Oliver Neukum <oliver@neukum.org>
> > Date:   Thu Dec 3 22:08:12 2009 +0100
> > 
> >     usbnet & cdc-ether: Autosuspend for online devices
> >     
> >     Using remote wakeup and delayed transmission to allow
> >     online device to go into usb autosuspend.
> >     Minimal alternate support for devices that don't support
> >     remote wakeup.
> >     
> >     Signed-off-by: Oliver Neukum <oliver@neukum.org>
> 
> Oliver, this patch still doesn't apply after patch #1 is
> added.

why don't you use git format-patch and git send-email. With that
combination it is almost impossible to screw up.

Regards

Marcel


