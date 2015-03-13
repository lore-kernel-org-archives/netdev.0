From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: [PATCH] ath10k: match wait_for_completion_timeout return type
Date: Fri, 13 Mar 2015 18:51:21 +0200
Message-ID: <87y4n0q1rq.fsf@kamboji.qca.qualcomm.com>
References: <1426094076-10134-1-git-send-email-hofrat@osadl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <linux-wireless@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <ath10k@lists.infradead.org>
To: Nicholas Mc Guire <hofrat@osadl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine01.qualcomm.com ([199.106.114.254]:4162 "EHLO
	wolverine01.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751491AbbCMQve (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 12:51:34 -0400
In-Reply-To: <1426094076-10134-1-git-send-email-hofrat@osadl.org> (Nicholas Mc
	Guire's message of "Wed, 11 Mar 2015 13:14:36 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nicholas Mc Guire <hofrat@osadl.org> writes:

> Return type of wait_for_completion_timeout is unsigned long not int.
> An appropriately named unsigned long is added and the assignments fixed up.
>
> Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>

Doesn't apply:

Applying: ath10k: match wait_for_completion_timeout return type
fatal: sha1 information is lacking or useless (drivers/net/wireless/ath/ath10k/mac.c).
Repository lacks necessary blobs to fall back on 3-way merge.
Cannot fall back to three-way merge.
Patch failed at 0001 ath10k: match wait_for_completion_timeout return type

-- 
Kalle Valo
