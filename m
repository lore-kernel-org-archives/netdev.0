From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 1/2] net: phy: broadcom: Update Auxiliary Control Register
 macros
Date: Fri, 21 Oct 2016 14:27:11 -0700
Message-ID: <24327979-0ff4-c4ed-d1c4-8724c65860b8@gmail.com>
References: <1477070413-92621-1-git-send-email-xow@google.com>
 <1477070413-92621-2-git-send-email-xow@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jaedon.shin@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, openbmc@lists.ozlabs.org,
        joel@jms.id.au
To: Xo Wang <xow@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1477070413-92621-2-git-send-email-xow@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/21/2016 10:20 AM, Xo Wang wrote:
> Add the RXD-to-RXC skew (delay) time bit in the Miscellaneous Control
> shadow register and a mask for the shadow selector field.
> 
> Remove a re-definition of MII_BCM54XX_AUXCTL_SHDWSEL_AUXCTL.
> 
> Signed-off-by: Xo Wang <xow@google.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
