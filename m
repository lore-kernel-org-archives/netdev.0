From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: dsa: mediatek: add adjust link support for user
 ports
Date: Tue, 08 Aug 2017 18:03:24 -0700 (PDT)
Message-ID: <20170808.180324.1537853260987687573.davem@davemloft.net>
References: <20170807142049.4144-1-john@phrozen.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, sean.wang@mediatek.com,
        Ryder.Lee@mediatek.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mediatek@lists.infradead.org,
        shashidhar.lakkavalli@openmesh.com, muciri@openmesh.com
To: john@phrozen.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170807142049.4144-1-john@phrozen.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: John Crispin <john@phrozen.org>
Date: Mon,  7 Aug 2017 16:20:49 +0200

> Manually adjust the port settings of user ports once PHY polling has
> completed. This patch extends the adjust_link callback to configure the
> per port PMCR register, applying the proper values polled from the PHY.
> Without this patch flow control was not always getting setup properly.
> 
> Signed-off-by: Shashidhar Lakkavalli <shashidhar.lakkavalli@openmesh.com>
> Signed-off-by: Muciri Gatimu <muciri@openmesh.com>
> Signed-off-by: John Crispin <john@phrozen.org>

Applied, thank you.
