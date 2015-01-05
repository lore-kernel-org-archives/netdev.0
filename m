From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH 23/23 V2 for 3.19]  rtlwifi: Fix error when accessing unmapped memory in skb
Date: Mon, 05 Jan 2015 11:20:54 +0200
Message-ID: <87387p4m89.fsf@kamboji.qca.qualcomm.com>
References: <1419711457-21469-1-git-send-email-Larry.Finger@lwfinger.net>
	<87a928726w.fsf@kamboji.qca.qualcomm.com>
	<549FA005.7050802@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Stable <stable@vger.kernel.org>,
	Eric Biggers <ebiggers3@gmail.com>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.11.231]:56243 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753282AbbAEJVB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 04:21:01 -0500
In-Reply-To: <549FA005.7050802@lwfinger.net> (Larry Finger's message of "Sun,
	28 Dec 2014 00:15:33 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Larry Finger <Larry.Finger@lwfinger.net> writes:

>> 23/23? Where are patches 1-22? I don't see them in patchwork:
>>
>> https://patchwork.kernel.org/project/linux-wireless/list/
>
> Sorry. I forgot to edit the subject line. To get git to format that
> one patch, I had to generate a total of 23. There is only 1 of 1 that
> will be submitted.

Ok, I was just worried that I had missed the other 22. But you can
actually get a single commit like this so no editing is needed:

git format-patch -1 2a3e60d37fc6

-- 
Kalle Valo
