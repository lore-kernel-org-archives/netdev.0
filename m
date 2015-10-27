From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH v4 14/15] net: wireless: ath: Remove unneeded variable ret returning 0
Date: Tue, 27 Oct 2015 10:12:19 +0200
Message-ID: <87a8r4ybks.fsf@kamboji.qca.qualcomm.com>
References: <1445539670-4018-1-git-send-email-punitvara@gmail.com>
	<5629316E.60106@cogentembedded.com>
	<CABXAfNJewoq3LL9S+cSEs3S+nQXN714JyKT_ys2+armMprVEgA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	jirislaby@gmail.com, Nick Kossifidis <mickflemm@gmail.com>,
	mcgrof@do-not-panic.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: punit vara <punitvara@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:57408 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753810AbbJ0IM3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 04:12:29 -0400
In-Reply-To: <CABXAfNJewoq3LL9S+cSEs3S+nQXN714JyKT_ys2+armMprVEgA@mail.gmail.com>
	(punit vara's message of "Tue, 27 Oct 2015 01:30:21 +0530")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

punit vara <punitvara@gmail.com> writes:

> Will my other patches which are already correct be added to wireless
> tree ? or I have to resend everything ?

Yes, please resend the whole patchset. I don't apply patches
individually from a patchset, it's just too time consuming and error
prone.

Also, as you seem to be new here, I don't recommend sending big
patchsets in the beginning. Start slow, send just few a patch or two at
a time, and once you gain more experience send bigger patchsets.

-- 
Kalle Valo
