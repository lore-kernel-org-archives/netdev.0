From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 net 7/8] net: bcmgenet: add begin/complete ethtool ops
Date: Thu, 9 Mar 2017 17:44:49 -0800
Message-ID: <22589f16-36ca-f55c-3bf4-e5c945a6ce10@gmail.com>
References: <20170310005850.10808-1-opendmb@gmail.com>
 <20170310005850.10808-8-opendmb@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: pgynther@google.com, jaedon.shin@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Edwin Chan <edwin.chan@broadcom.com>
To: Doug Berger <opendmb@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170310005850.10808-8-opendmb@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/09/2017 04:58 PM, Doug Berger wrote:
> From: Edwin Chan <edwin.chan@broadcom.com>
> 
> Make sure clock is enabled for ethtool ops.
> 
> Fixes: 1c1008c793fa ("net: bcmgenet: add main driver file")
> Signed-off-by: Edwin Chan <edwin.chan@broadcom.com>
> Signed-off-by: Doug Berger <opendmb@gmail.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
