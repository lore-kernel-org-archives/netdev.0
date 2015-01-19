From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: [discuss] [cdc_ncm] Refactoring cdc_ncm
Date: Mon, 19 Jan 2015 17:51:57 +0100 (CET)
Message-ID: <alpine.LNX.2.03.1501191743360.2081@gmail.com>
References: <AMSPR06MB6011E001029C251790CB923EE780@AMSPR06MB601.eurprd06.prod.outlook.com> <877fy7myfb.fsf@nemi.mork.no> <alpine.LNX.2.03.1412041326160.9926@gmail.com> <54811670.5030703@audiocodes.com> <8761dqjuuh.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Kevin Zhu <Mingying.Zhu@audiocodes.com>,
	Midge Shaojun Tan <ShaojunMidge.Tan@audiocodes.com>,
	Eli Britstein <Eli.Britstein@audiocodes.com>,
	Alex Strizhevsky <alexxst@gmail.com>,
	"youtux@gmail.com" <youtux@gmail.com>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: =?ISO-8859-15?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:49773 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751401AbbASQvh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2015 11:51:37 -0500
In-Reply-To: <8761dqjuuh.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi guys.
I am noticing that in kernel 3.19rc4, the driver from huawei,
hw_cdc_driver
is not able to perform the call to
netif_msg_ifup anymore (receives error -13).
This to say that it would be very important to continue the work on refactoring 
cdc_ncm.c driver to let it work with newer huawei devices such as the E3372 
even at full rates.
I received some acks regarding the patches I sent last time - and I am grateful 
to you all maintainers / reviewers. I have actually not received acks for all 
the patches so I preferred waiting and not continously re-sending again.
This also happened due to me getting very busy lately with studying.
So the situation is getting complicated.
I sent this mail to everyone just to keep you up-to-date. Don't worry.
Any help from any developer interested would be very apreciated.
I would need some mentoring or help in general with coding.

Thank you all very much.

Sincerely.

Enrico
