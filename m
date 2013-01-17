From: Sachin Kamat <sachin.kamat@linaro.org>
Subject: Re: [PATCH 1/1] net: mvneta: Remove unneeded version.h header inclusion
Date: Thu, 17 Jan 2013 08:30:10 +0530
Message-ID: <CAK9yfHx0otv2vhXYORQWjPSB2197KjKBDGoro+_Mu-4mBSH9=w@mail.gmail.com>
References: <1354527928-27472-1-git-send-email-sachin.kamat@linaro.org>
	<20121203.134620.972752091312747013.davem@davemloft.net>
	<20121203195826.679f70d4@skate>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f48.google.com ([209.85.219.48]:35344 "EHLO
	mail-oa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758999Ab3AQDAL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2013 22:00:11 -0500
Received: by mail-oa0-f48.google.com with SMTP id h2so2147531oag.7
        for <netdev@vger.kernel.org>; Wed, 16 Jan 2013 19:00:11 -0800 (PST)
In-Reply-To: <20121203195826.679f70d4@skate>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Thomas,

On 4 December 2012 00:28, Thomas Petazzoni
<thomas.petazzoni@free-electrons.com> wrote:
> Dear David Miller,
>
> On Mon, 03 Dec 2012 13:46:20 -0500 (EST), David Miller wrote:
>> From: Sachin Kamat <sachin.kamat@linaro.org>
>> Date: Mon,  3 Dec 2012 15:15:28 +0530
>>
>> > linux/version.h inclusion is not necessary.
>> >
>> > Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
>>
>> Acked-by: David S. Miller <davem@davemloft.net>
>>
>> I hope the mvneta folks will pick this up and apply it where it
>> needs to be as the mvneta driver isn't in the net-next tree.
>
> Yes, I will pick it up, and send a pull request to the Marvell
> maintainers. I have other mvneta fixes that I'll send together with
> this one.

Can you please share the git repo link where this patch is lined up ATM?


>
> Thanks,
>
> Thomas
> --
> Thomas Petazzoni, Free Electrons
> Kernel, drivers, real-time and embedded Linux
> development, consulting, training and support.
> http://free-electrons.com



-- 
With warm regards,
Sachin
