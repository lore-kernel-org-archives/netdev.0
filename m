From: Alexey ORISHKO <alexey.orishko@stericsson.com>
Subject: RE: removing the timer from cdc-ncm
Date: Mon, 24 Sep 2012 14:13:50 +0200
Message-ID: <2AC7D4AD8BA1C640B4C60C61C8E520154A8BED545F@EXDCVYMBSTM006.EQ1STM.local>
References: <6020948.EvS2esPpc0@linux-lqwf.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "bjorn@mork.no" <bjorn@mork.no>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: Oliver Neukum <oneukum@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog112.obsmtp.com ([207.126.144.133]:47831 "EHLO
	eu1sys200aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754495Ab2IXMOS convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Sep 2012 08:14:18 -0400
In-Reply-To: <6020948.EvS2esPpc0@linux-lqwf.site>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Oliver Neukum [mailto:oneukum@suse.de]
> Sent: Friday, September 21, 2012 10:35 AM
> To: Alexey ORISHKO; bjorn@mork.no; netdev@vger.kernel.org; linux-
> usb@vger.kernel.org
> Subject: removing the timer from cdc-ncm
> 
> Hi,
> 
> here is the patch that does everything I consider theoretically
> necessary to have bundling of frames in usbnet and adapting cdc-ncm to
> it.
> 
> I'd appreciate any review in case I am doing something stupid.

Hi Oliver,

I've tried to apply it, but always got a message that "patch does not apply".
What is the base for this patch?

Regards,
Alexey
