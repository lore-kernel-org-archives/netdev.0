From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 net 2/8] net: bcmgenet: correct MIB access of UniMAC
 RUNT counters
Date: Thu, 9 Mar 2017 17:43:00 -0800
Message-ID: <d70aba1f-72a5-0249-ccbc-36aed509ae8b@gmail.com>
References: <20170310005850.10808-1-opendmb@gmail.com>
 <20170310005850.10808-3-opendmb@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: pgynther@google.com, jaedon.shin@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Doug Berger <opendmb@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170310005850.10808-3-opendmb@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/09/2017 04:58 PM, Doug Berger wrote:
> The gap between the Tx status counters and the Rx RUNT counters is now
> being added to allow correct reporting of the registers.
> 
> Fixes: 1c1008c793fa ("net: bcmgenet: add main driver file")
> Signed-off-by: Doug Berger <opendmb@gmail.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
