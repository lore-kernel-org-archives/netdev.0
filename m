From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 3/4] net: phy: Add Broadcom phy library for common interfaces
Date: Wed, 30 Sep 2015 14:35:11 -0700
Message-ID: <560C558F.7010106@gmail.com>
References: <1443645163-2822-1-git-send-email-arunp@broadcom.com> <1443645163-2822-4-git-send-email-arunp@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
	bcm-kernel-feedback-list@broadcom.com
To: Arun Parameswaran <arunp@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443645163-2822-4-git-send-email-arunp@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 30/09/15 13:32, Arun Parameswaran wrote:
> This patch adds the Broadcom phy library to consolidate common
> interfaces shared by Broadcom phy's.
> 
> Moved the common interfaces to the 'bcm-phy-lib.c' and updated
> the Broadcom PHY drivers to use the new APIs.
> 
> Signed-off-by: Arun Parameswaran <arunp@broadcom.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

On BCM7xxx:
Tested-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
