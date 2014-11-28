From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: Re: Is this 32-bit NCM?
Date: Fri, 28 Nov 2014 07:23:13 +0100 (CET)
Message-ID: <alpine.LNX.2.03.1411280718230.1315@gmail.com>
References: <alpine.LNX.2.03.1411262250160.4356@gmail.com> <87ppc957h1.fsf@nemi.mork.no> <alpine.LNX.2.03.1411271037050.9464@gmail.com> <874mtl55ar.fsf@nemi.mork.no> <CAPChA0cLuvRpYTYuFoi3bewqASgf_oZHSz5yQQ8JYm96dZ4-TQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: =?ISO-8859-15?Q?Bj=F8rn_Mork?= <bjorn@mork.no>,
	ShaojunMidge.Tan@audiocodes.com, Mingying.Zhu@audiocodes.com,
	youtux@gmail.com, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, Eli.Britstein@audiocodes.com
To: Alex Strizhevsky <alexxst@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:38785 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751218AbaK1GWp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Nov 2014 01:22:45 -0500
In-Reply-To: <CAPChA0cLuvRpYTYuFoi3bewqASgf_oZHSz5yQQ8JYm96dZ4-TQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

And... a precisation: when I talk about the 32-bit mode driver, I am not 
referring to the windows one, but to the Linux one I and Alessio "implemented", 
modifying the standard cdc_ncm.c driver.
This version of the driver should be available here:


On Thu, 27 Nov 2014, Alex Strizhevsky wrote:
http://www.gstorm.eu/cdc_ncm.c

And you might compile it with a kernel >= 3.16.
Overmore, if this driver is able to work with E3272, you might compare it with 
the Windows driver in E3272 and then compare differences when working with 
E3276.
Please Kevin, Midge, and anyone who want to help: do your best. I can't do much 
because I don't have non-working device and a Windows installation ready at 
hand; but the real problem is the devices.
But for me this is a personal challenge - a matter of heart; and solving this 
problem means solving lots of them in future maybe.
So - waiting for any data and consideration.
If you need anything by my side - you know where you can find me:
- here
- or use this mail address as google talk messaging + google plus; and this is 
true even for who is reading linux-usb and netdev mailing lists.
Enrico
