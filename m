From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH V2 for 3.19 0/7] Fixes for rtl8192ee
Date: Fri, 23 Jan 2015 22:24:10 +0200
Message-ID: <87egqljled.fsf@kamboji.qca.qualcomm.com>
References: <1421773286-1039-1-git-send-email-Larry.Finger@lwfinger.net>
	<873871msc7.fsf@kamboji.qca.qualcomm.com>
	<54C27975.50501@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	=?utf-8?Q?tr?=
	 =?utf-8?Q?oy=5Ftan=40realsil=2Ecom=2Ecn_=3E=3E_=E8=B0=AD=E6=9D=AD?=
	 =?utf-8?Q?=E6=B3=A2?= <troy_tan@realsil.com.cn>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.11.231]:47415 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755381AbbAWUYR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2015 15:24:17 -0500
In-Reply-To: <54C27975.50501@lwfinger.net> (Larry Finger's message of "Fri, 23
	Jan 2015 10:40:21 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Larry Finger <Larry.Finger@lwfinger.net> writes:

> It is too bad that it took so long to get these ready. I think the
> reason that there are not a lot of bug reports is because the
> complaints are all in the GitHub issues for the rtlwifi_new repo, or
> with Ubuntu. If there are any that get filed against Bugzilla, I will
> refer them to that repo.

Ok.

> Driver rtl8192ee was new in 3.18. There had been a previous version in
> staging, but it did not get a lot of usage. I'm not sure if the
> additional usage after 3.18 was due to the driver being in the regular
> tree, or if vendors started using the chips, but the problem reports
> started arriving. All these bugs have been part of rtl8192ee since it
> has been in the kernel, thus they are hard to categorize as
> regressions.

Good. So we are not going backwards in quality, that's most important.

> Push all 7 into -next so that they will be in 3.20. If you think it to
> be prudent, please leave the Cc for stable. That way 3.18 and 3.19
> will eventually get the fixes.

I think that's the best plan, thanks for understanding. The patches are
in my queue and I should apply them within the next few days, unless
anything comes during the review.

-- 
Kalle Valo
