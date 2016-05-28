From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: wifi: ath6kl: simplify logical condition
Date: Sat, 28 May 2016 10:23:50 +0200
Message-ID: <01f13acfb14a475abc4a9b3c4b5a578b@euamsexm01a.eu.qualcomm.com>
References: <1463531057-12917-1-git-send-email-xypron.glpk@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <linux-wireless@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	Heinrich Schuchardt <xypron.glpk@gmx.de>
To: Heinrich Schuchardt <xypron.glpk@gmx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463531057-12917-1-git-send-email-xypron.glpk@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Heinrich Schuchardt <xypron.glpk@gmx.de> wrote:
> x <= 7 implies x < 8.
> 
> Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>

Thanks, 1 patch applied to ath.git:

93b4a09f0f30 ath6kl: simplify logical condition

-- 
Sent by pwcli
https://patchwork.kernel.org/patch/9115691/
