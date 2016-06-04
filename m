From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [v2] carl9170: Clarify kconfig text
Date: Sat,  4 Jun 2016 14:58:35 +0000 (UTC)
Message-ID: <20160604145835.EE22A613CF@smtp.codeaurora.org>
References: <20160416171856.1769c0e16bcc75372407e06f@gmx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Christian Lamparter <chunkeey@googlemail.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Lauri Kasanen <cand@gmx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160416171856.1769c0e16bcc75372407e06f@gmx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Lauri Kasanen <cand@gmx.com> wrote:
> The previous text was confusing, leading readers to think this
> driver was a duplicate, and so didn't need to be enabled.
> 
> After the removal of the older staging driver, this is the only
> driver in mainline for these devices.
> 
> Signed-off-by: Lauri Kasanen <cand@gmx.com>
> Acked-by: Christian Lamparter <chunkeey@googlemail.com>

Thanks, 1 patch applied to wireless-drivers-next.git:

83e41e77819b carl9170: Clarify kconfig text

-- 
Sent by pwcli
https://patchwork.kernel.org/patch/8861621/
