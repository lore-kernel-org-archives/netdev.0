From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: phy: at803x: support interrupt on 8030 and 8035
Date: Thu, 12 Nov 2015 11:15:13 -0800
Message-ID: <5644E541.7070109@gmail.com>
References: <1447350020-27969-1-git-send-email-mans@mansr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: slash.tmp@free.fr
To: Mans Rullgard <mans@mansr.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1447350020-27969-1-git-send-email-mans@mansr.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/11/15 09:40, Mans Rullgard wrote:
> Commit 77a993942 "phy/at8031: enable at8031 to work on interrupt mode"
> added interrupt support for the 8031 PHY but left out the other two
> chips supported by this driver.
> 
> This patch sets the .ack_interrupt and .config_intr functions for the
> 8030 and 8035 drivers as well.
> 
> Signed-off-by: Mans Rullgard <mans@mansr.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
