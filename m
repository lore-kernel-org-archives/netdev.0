From: Florian Fainelli <florian.fainelli@broadcom.com>
Subject: Re: [PATCH v5 1/7] net: phy: broadcom: add bcm54xx_auxctl_read
Date: Wed, 2 Nov 2016 10:11:29 -0700
Message-ID: <996f1a15-02ad-cc6f-4889-e4fe6a311639@broadcom.com>
References: <1478106488-11779-1-git-send-email-jon.mason@broadcom.com>
 <1478106488-11779-2-git-send-email-jon.mason@broadcom.com>
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
In-Reply-To: <1478106488-11779-2-git-send-email-jon.mason@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/02/2016 10:08 AM, Jon Mason wrote:
> Add a helper function to read the AUXCTL register for the BCM54xx.  This
> mirrors the bcm54xx_auxctl_write function already present in the code.
> 
> Signed-off-by: Jon Mason <jon.mason@broadcom.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
