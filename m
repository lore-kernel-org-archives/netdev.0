From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 2/2] net: phy: broadcom: Add support for BCM54612E
Date: Fri, 21 Oct 2016 14:31:32 -0700
Message-ID: <964d671f-8994-802a-11a1-af16170e9b8f@gmail.com>
References: <1477070413-92621-1-git-send-email-xow@google.com>
 <1477070413-92621-3-git-send-email-xow@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jaedon.shin@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, openbmc@lists.ozlabs.org,
        joel@jms.id.au
To: Xo Wang <xow@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1477070413-92621-3-git-send-email-xow@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/21/2016 10:20 AM, Xo Wang wrote:
> This PHY has internal delays enabled after reset. This clears the
> internal delay enables unless the interface specifically requests them.
> 
> Signed-off-by: Xo Wang <xow@google.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

Cross checked with the datasheet, this all looks correct to me, thanks!
-- 
Florian
