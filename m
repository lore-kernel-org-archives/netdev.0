From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: [PATCH] ath10k: debug: match wait_for_completion_timeout return type
Date: Wed, 1 Apr 2015 20:16:24 +0300
Message-ID: <87619fzs47.fsf@kamboji.qca.qualcomm.com>
References: <1426325830-19740-1-git-send-email-hofrat@osadl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <linux-wireless@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <ath10k@lists.infradead.org>
To: Nicholas Mc Guire <hofrat@osadl.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1426325830-19740-1-git-send-email-hofrat@osadl.org> (Nicholas Mc
	Guire's message of "Sat, 14 Mar 2015 05:37:10 -0400")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Nicholas Mc Guire <hofrat@osadl.org> writes:

> Return type of wait_for_completion_timeout is unsigned long not int.
> An appropriately named unsigned long is added and the assignments fixed up.
> Missing spaces 1*HZ -> 1 * HZ were also added along the way.
>
> Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>

Thanks, applied.

-- 
Kalle Valo
