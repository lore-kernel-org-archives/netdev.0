From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [v2] mwifiex: correctly handling kzalloc
Date: Thu,  7 Jan 2016 09:12:30 +0000 (UTC)
Message-ID: <20160107091230.C5B58605BF@smtp.codeaurora.org>
References: <1451491304-35251-1-git-send-email-wuninsu@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: akarwar@marvell.com, nishants@marvell.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, taesoo@gatech.edu,
	yeongjin.jang@gatech.edu, insu@gatech.edu, changwoo@gatech.edu,
	Insu Yun <wuninsu@gmail.com>
To: Insu Yun <wuninsu@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1451491304-35251-1-git-send-email-wuninsu@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Since kzalloc can be failed in memory pressure,
> it needs to be handled, otherwise NULL dereference could be happened
> 
> Signed-off-by: Insu Yun <wuninsu@gmail.com>

Thanks, applied to wireless-drivers-next.git.

Kalle Valo
