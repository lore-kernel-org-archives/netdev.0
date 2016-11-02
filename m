From: Florian Fainelli <florian.fainelli@broadcom.com>
Subject: Re: [PATCH v5 3/7] net: phy: broadcom: Add BCM54810 PHY entry
Date: Wed, 2 Nov 2016 10:12:25 -0700
Message-ID: <c8d6f062-f5f4-dc07-4cc6-33dbe2c22943@broadcom.com>
References: <1478106488-11779-1-git-send-email-jon.mason@broadcom.com>
 <1478106488-11779-4-git-send-email-jon.mason@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: rafal@milecki.pl, bcm-kernel-feedback-list@broadcom.com,
        netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Jon Mason <jon.mason@broadcom.com>,
        David Miller <davem@davemloft.net>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1478106488-11779-4-git-send-email-jon.mason@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/02/2016 10:08 AM, Jon Mason wrote:
> The BCM54810 PHY requires some semi-unique configuration, which results
> in some additional configuration in addition to the standard config.
> Also, some users of the BCM54810 require the PHY lanes to be swapped.
> Since there is no way to detect this, add a device tree query to see if
> it is applicable.
> 
> Inspired-by: Vikas Soni <vsoni@broadcom.com>
> Signed-off-by: Jon Mason <jon.mason@broadcom.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
