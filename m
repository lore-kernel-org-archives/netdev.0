From: "Stefan Bottelier | Ocius.nl" <stefan@ocius.nl>
Subject: Re: Problem with 10Gbit Broadcom NetXtreme II 5771x/578xx 10/20-Gigabit
 Ethernet Driver
Date: Mon, 27 Oct 2014 09:42:36 +0100
Message-ID: <544E057C.2070204@ocius.nl>
References: <544A110C.4030402@ocius.nl> <B5657A6538887040AD3A81F1008BEC63B85038@avmb3.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Axlion.ocius.nl ([178.18.143.21]:15465 "EHLO Axlion.ocius.nl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751230AbaJ0Iml (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Oct 2014 04:42:41 -0400
In-Reply-To: <B5657A6538887040AD3A81F1008BEC63B85038@avmb3.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Yuval,

Thanks for this messages.

We use now the kernel 3.10.57 and then the interface working, only we 
must back to the kernel we always use 3.2.63 , its work better with use 
systems.
I have compiler the kernel by my self on a Suse system.

I hope we can fix it, that this working with the kernel 3.2.63.

>> We are using Dell Blade Centers, but we get a error on the 10Gbit
>> Broadcom adapter bnx2x
>> bnx2x 0000:01:00.0: part number 394D4342-31383735-30315430-473030
>> WARNING: at drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:9410
> Hi Stefan,
>
> Which distro & linux kernel are you using?
> [Obviously not net-next]
>
> Thanks,
> Yuval
>
> ________________________________
>
> This message and any attached documents contain information from the sending company or its parent company(s), subsidiaries, divisions or branch offices that may be confidential. If you are not the intended recipient, you may not read, copy, distribute, or use this information. If you have received this transmission in error, please notify the sender immediately by reply e-mail and then delete this message.


-- 
Met vriendelijke groet,

Stefan Bottelier
Ocius Internet Services

E: Stefan.Bottelier@ocius.nl
T: +31 (0)20 716 39 09
W: http://www.ocius.nl
