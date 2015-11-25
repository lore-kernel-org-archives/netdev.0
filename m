From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH v2 06/27] brcm80211: move under broadcom vendor directory
Date: Wed, 25 Nov 2015 11:17:57 +0200
Message-ID: <87egfephdm.fsf@kamboji.qca.qualcomm.com>
References: <1447857966-19560-1-git-send-email-kvalo@codeaurora.org>
	<1447857966-19560-7-git-send-email-kvalo@codeaurora.org>
	<564CCF2A.4030203@hauke-m.de>
	<871tbmwhsk.fsf@kamboji.qca.qualcomm.com>
	<564F966A.7080300@broadcom.com>
	<87lh9qrlra.fsf@kamboji.qca.qualcomm.com>
	<5652EA61.1080103@broadcom.com> <5652EC10.9010708@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hauke Mehrtens <hauke@hauke-m.de>,
	<linux-wireless@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <brcm80211-dev-list@broadcom.com>
To: Arend van Spriel <arend@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:35724 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932282AbbKYJSE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2015 04:18:04 -0500
In-Reply-To: <5652EC10.9010708@broadcom.com> (Arend van Spriel's message of
	"Mon, 23 Nov 2015 11:36:00 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arend van Spriel <arend@broadcom.com> writes:

>>>> I prefer to keep it as brcmsmac and brcmfmac rely on brcmutil module
>>>> so I want to keep them together under brcm80211.
>>>>
>>>> So does this patch go in before or after the patches I submitted
>>>> before the merge window. I hope after :-p
>>>
>>> Sorry, the vendor patches go in first :) It's much safer that way.
>>>
>>> But I think that git should be smart enough and your patchset from
>>> before the merge window should still apply without issues.
>>
>> Will see if that is true when I merge it in our internal repo. :-p
>
> Just applied the pending patches using 'git am -3' and that works
> fine. So when told to be smart, git is indeed smart ;-)

Git is awesome :) Thanks for checking.

-- 
Kalle Valo
