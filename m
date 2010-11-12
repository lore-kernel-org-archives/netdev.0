From: Ramkrishna Vepa <Ramkrishna.Vepa@exar.com>
Subject: RE: [PATCH] vxge: update firmware to version 1.8.1
Date: Thu, 11 Nov 2010 16:52:08 -0800
Message-ID: <FCA91A92EE52B041906A0358FC28FCC38EF64B4A15@FRE1EXCH02.hq.exar.com>
References: <1289521154-16377-1-git-send-email-jon.mason@exar.com>
 <1289521353.9408.92.camel@i7.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Sivakumar Subramani <Sivakumar.Subramani@exar.com>,
	Sreenivasa Honnur <Sreenivasa.Honnur@exar.com>
To: David Woodhouse <dwmw2@infradead.org>,
	Jon Mason <Jon.Mason@exar.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.exar.com ([204.154.183.83]:7923 "EHLO smtp1.exar.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751505Ab0KLA5P convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 19:57:15 -0500
In-Reply-To: <1289521353.9408.92.camel@i7.infradead.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

Yes, this firmware is compatible with the driver currently in the kernel. No driver change is required to work with this firmware version.

Thanks,
Ram
> -----Original Message-----
> From: David Woodhouse [mailto:dwmw2@infradead.org]
> Sent: Thursday, November 11, 2010 4:23 PM
> To: Jon Mason
> Cc: netdev@vger.kernel.org; Sivakumar Subramani; Sreenivasa Honnur;
> Ramkrishna Vepa
> Subject: Re: [PATCH] vxge: update firmware to version 1.8.1
>
> On Thu, 2010-11-11 at 18:19 -0600, Jon Mason wrote:
> > Update firmware for the Exar X3100 10Gbps adapters to version 1.8.1
>
> This is a compatible change which doesn't require driver changes?
>
> --
> dwmw2


The information and any attached documents contained in this message
may be confidential and/or legally privileged.  The message is
intended solely for the addressee(s).  If you are not the intended
recipient, you are hereby notified that any use, dissemination, or
reproduction is strictly prohibited and may be unlawful.  If you are
not the intended recipient, please contact the sender immediately by
return e-mail and destroy all copies of the original message.
