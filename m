From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [1/1] mwifiex: illegal assignment
Date: Tue, 14 Jun 2016 14:19:50 +0000 (UTC)
Message-ID: <20160614141950.158DC61404@smtp.codeaurora.org>
References: <1463526118-11822-1-git-send-email-xypron.glpk@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Amitkumar Karwar <akarwar@marvell.com>,
	Nishant Sarmukadam <nishants@marvell.com>,
	Xinming Hu <huxm@marvell.com>, Cathy Luo <cluo@marvell.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Heinrich Schuchardt <xypron.glpk@gmx.de>
To: Heinrich Schuchardt <xypron.glpk@gmx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463526118-11822-1-git-send-email-xypron.glpk@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Heinrich Schuchardt <xypron.glpk@gmx.de> wrote:
> Variable adapter is incorrectly initialized.
> 
> Fixes: bf00dc22bc7a ("mwifiex: AMSDU Rx frame handling in AP mode")
> Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>
> Acked-by: Amitkumar Karwar <akarwar@marvell.com>

Thanks, 1 patch applied to wireless-drivers-next.git:

3fdbda446fbc mwifiex: illegal assignment

-- 
Sent by pwcli
https://patchwork.kernel.org/patch/9115501/
