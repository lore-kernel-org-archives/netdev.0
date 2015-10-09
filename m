From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH v2] ath6kl: drop unlikely behind WARN_ON()
Date: Fri, 09 Oct 2015 11:49:02 +0300
Message-ID: <87vbagqvep.fsf@kamboji.qca.qualcomm.com>
References: <61de1b17c432479ccded41edfb553e2d20ebf8ae.1444048783.git.geliangtang@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Geliang Tang <geliangtang@163.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <61de1b17c432479ccded41edfb553e2d20ebf8ae.1444048783.git.geliangtang@163.com>
	(Geliang Tang's message of "Mon, 5 Oct 2015 20:46:12 +0800")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Geliang Tang <geliangtang@163.com> writes:

> WARN_ON() already contain an unlikely compiler flag. Drop it.
>
> Signed-off-by: Geliang Tang <geliangtang@163.com>

Applied, thanks.

-- 
Kalle Valo
