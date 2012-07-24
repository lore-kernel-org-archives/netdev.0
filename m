From: kyak <bas@bmail.ru>
Subject: Re: [PATCH] USB: plusb: Add support for PL-2501
Date: Tue, 24 Jul 2012 09:39:40 +0400 (MSK)
Message-ID: <alpine.LNX.2.02.1207240930140.1183@bas>
References: <alpine.LNX.2.02.1207231540580.1183@bas> <20120723.130835.1217772163295796220.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: bas@bmail.ru, linux-kernel@vger.kernel.org, sshtylyov@mvista.com,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org, greg@kroah.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bmail.ru ([194.67.1.203]:30487 "EHLO sovam.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751378Ab2GXFjo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jul 2012 01:39:44 -0400
In-Reply-To: <20120723.130835.1217772163295796220.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch was created against linux-3.5, but it applies perfectly 
against net-next tree, i just checked..

I'm sorry for not being able to submit the correct patch from the first 
attempt (and not even from the third attempt). Could you be more specific 
about "doesn't apply cleanly at all"? By the way, i'm perfectly fine if 
you just make this trivial change by yourself and take the credit, because 
our exchange of e-mails has become 20 times bigger than the patch 
itself. Probably sending another version of this patch from my side would 
be just another waste of (your) time.

On Mon, 23 Jul 2012, David Miller wrote:

> From: kyak <bas@bmail.ru>
> Date: Mon, 23 Jul 2012 15:44:11 +0400 (MSK)
>
>> From: Mikhail Peselnik <peselnik@gmail.com>
>>
>> This patch adds support for PL-2501 by adding the appropriate USB
>> ID's. This chip is used in several USB 'Easy Trasfer' Cables.
>>
>> Signed-off-by: Mikhail Peselnik <peselnik@gmail.com>
>> Tested-by: Mikhail Peselnik <peselnik@gmail.com>
>
> This does not apply cleanly to my net-next tree at all.
>
