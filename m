From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [1/1] mwifiex: key_material_v2 remove superfluous condition
Date: Sat,  3 Sep 2016 10:00:52 +0000 (UTC)
Message-ID: <20160903100052.D26F461B13@smtp.codeaurora.org>
References: <1469967081-3937-1-git-send-email-xypron.glpk@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Amitkumar Karwar <akarwar@marvell.com>,
        Nishant Sarmukadam <nishants@marvell.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Heinrich Schuchardt <xypron.glpk@gmx.de>
To: Heinrich Schuchardt <xypron.glpk@gmx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1469967081-3937-1-git-send-email-xypron.glpk@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Heinrich Schuchardt <xypron.glpk@gmx.de> wrote:
> We are using mac as source address in a memcpy.
> In the lines below we can assume mac is not NULL.
> 
> Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>
> Acked-by: Amitkumar Karwar <akarwar@marvell.com>

Thanks, 1 patch applied to wireless-drivers-next.git:

b0d80f19c14f mwifiex: key_material_v2 remove superfluous condition

-- 
Sent by pwcli
https://patchwork.kernel.org/patch/9253367/
