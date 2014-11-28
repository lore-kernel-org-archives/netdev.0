From: Kevin Zhu <Mingying.Zhu@audiocodes.com>
Subject: Re: Is this 32-bit NCM?
Date: Fri, 28 Nov 2014 09:25:33 +0000
Message-ID: <54783F84.20105@audiocodes.com>
References: <alpine.LNX.2.03.1411262250160.4356@gmail.com>
 <87ppc957h1.fsf@nemi.mork.no> <alpine.LNX.2.03.1411271037050.9464@gmail.com>
 <874mtl55ar.fsf@nemi.mork.no>
 <CAPChA0cLuvRpYTYuFoi3bewqASgf_oZHSz5yQQ8JYm96dZ4-TQ@mail.gmail.com>
 <54781523.6030600@audiocodes.com>
 <alpine.LNX.2.03.1411280923230.3997@gmail.com>
 <54783443.50700@audiocodes.com>
 <alpine.LNX.2.03.1411280944200.4040@gmail.com>
 <54783A1D.3090607@audiocodes.com>
 <alpine.LNX.2.03.1411281014450.4101@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Alex Strizhevsky <alexxst@gmail.com>,
	=?Windows-1252?Q?Bj=F8rn_Mork?= <bjorn@mork.no>,
	"Midge Shaojun Tan" <ShaojunMidge.Tan@audiocodes.com>,
	"youtux@gmail.com" <youtux@gmail.com>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eli Britstein <Eli.Britstein@audiocodes.com>
To: Enrico Mioso <mrkiko.rs@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1lrp0013.outbound.protection.outlook.com ([213.199.154.13]:27776
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751824AbaK1JZg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Nov 2014 04:25:36 -0500
In-Reply-To: <alpine.LNX.2.03.1411281014450.4101@gmail.com>
Content-Language: en-US
Content-ID: <F637F184FA315542AF6FB8FE8D8F0582@eurprd06.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The only difference I can tell now is windows does not pack the NDP with
zeros, it just sends whatever the skb buffer has, except the alignment.

Regards,
Kevin

On 11/28/2014 05:17 PM, Enrico Mioso wrote:
> Sorry - resending message to all.
> Is the MAC right? In my case it was, but ... you never know.
> And - have you tried the promisc mode, just in case... don't know if this might
> even be implementedi n the driver, think not, but...
> I don't know what to think anymore.
> this ARP packet seems the same as with windows... but might be it's only my
> impression.
This email and any files transmitted with it are confidential material. They are intended solely for the use of the designated individual or entity to whom they are addressed. If the reader of this message is not the intended recipient, you are hereby notified that any dissemination, use, distribution or copying of this communication is strictly prohibited and may be unlawful.

If you have received this email in error please immediately notify the sender and delete or destroy any copy of this message
