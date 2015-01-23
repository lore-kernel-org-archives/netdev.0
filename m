From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: p54pci: add handling of signal case
Date: Fri, 23 Jan 2015 19:37:41 +0000 (UTC)
Message-ID: <20150123193741.62BD8141EB5@smtp.codeaurora.org>
References: <1421731577-13324-1-git-send-email-der.herr@hofr.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Christian Lamparter <chunkeey@googlemail.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Nicholas Mc Guire <der.herr@hofr.at>
To: Nicholas Mc Guire <der.herr@hofr.at>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1421731577-13324-1-git-send-email-der.herr@hofr.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> if(!wait_for_completion_interruptible_timeout(...))
> only handles the timeout case - this patch adds handling the
> signal case the same as timeout.
> 
> Signed-off-by: Nicholas Mc Guire <der.herr@hofr.at>
> Acked-by: Christian Lamparter <chunkeey@googlemail.com>

Thanks, applied to wireless-drivers-next.git. I remove the useless "wireless: "
from the title.

Kalle Valo
