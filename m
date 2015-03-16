From: Christoph Schulz <develop@kristov.de>
Subject: Re: [PATCH iproute2] ip: allow using a device "help" (or a prefix
 thereof)
Date: Mon, 16 Mar 2015 01:14:17 +0100
Message-ID: <20150316011417.18795qnb5rfzuamx@berry.schulz.ip-v6.eu>
References: <1426462817-18366-1-git-send-email-develop@kristov.de>
 <20150315234917.GA7105@angus-think.lan>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8;
 DelSp="Yes";
 format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leonhard@pre.is
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server1137-han.de-nserver.de ([85.158.180.102]:53076 "EHLO
	server1137-han.de-nserver.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751450AbbCPAOV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 20:14:21 -0400
In-Reply-To: <20150315234917.GA7105@angus-think.lan>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

Vadim Kochan schrieb am Mon, 16 Mar 2015 01:49:17 +0200:

> I don't know if it is important but I see this patch in the patchwork
>
> 	http://patchwork.ozlabs.org/patch/450257/
>
> as superseded, is it OK ?

Yes and no. The patch in the patchwork is based on my first answer to  
your email and is not fully correct. Today I re-analysed and  
overhauled it, so I marked the old patch as "superseded" in the  
patchwork. Then I tried twice to send the corrected patch (with  
another subject, by the way) via "git send-email" to netdev, but both  
times it didn't work -- the email *did* leave my host, but it  
apparently never made it to the mailing list. I don't know why. I have  
not received any bounces either so far. If my email does not show up  
eventually, I will resend it using a normal email client.


Regards,

Christoph Schulz
