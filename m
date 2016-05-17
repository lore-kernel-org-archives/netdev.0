From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: pull-request: wireless-drivers-next 2016-05-13
Date: Tue, 17 May 2016 09:43:34 +0300
Message-ID: <8737ph89rd.fsf@kamboji.qca.qualcomm.com>
References: <87oa8ab3eo.fsf@kamboji.qca.qualcomm.com>
	<87wpmu87ns.fsf@kamboji.qca.qualcomm.com>
	<87futi858q.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	luciano.coelho@intel.com, emmanuel.grumbach@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:38226 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754036AbcEQGnl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2016 02:43:41 -0400
In-Reply-To: <87futi858q.fsf@kamboji.qca.qualcomm.com> (Kalle Valo's message
	of "Mon, 16 May 2016 17:08:53 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Kalle Valo <kvalo@codeaurora.org> writes:

> Kalle Valo <kvalo@codeaurora.org> writes:
>
>> Kalle Valo <kvalo@codeaurora.org> writes:
>>
>>>   git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-next.git tags/wireless-drivers-next-for-davem-2016-05-13
>>
>> Please don't pull this yet, there might be something wrong now with
>> merges and need to check that first.
>
> Ok, like discussed in thread "linux-next: manual merge of the
> wireless-drivers-next tree with the net-next tree" there seems to be a
> problem on net-next in function iwl_mvm_set_tx_cmd(). Here is how I
> propose to fix this.

I noticed that you had marked this as Superseded in pathwork[1]. I was
actually hoping that you would pull this with the instructions how to
fix the conflict. But do you actually want me to resubmit the pull
request? Or something else?

[1] https://patchwork.ozlabs.org/patch/621953/

-- 
Kalle Valo
