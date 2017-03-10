From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 net 4/8] net: bcmgenet: power down internal phy if open
 or resume fails
Date: Thu, 9 Mar 2017 17:43:32 -0800
Message-ID: <bebf2951-8b94-ad18-5f5d-e4eda3e80528@gmail.com>
References: <20170310005850.10808-1-opendmb@gmail.com>
 <20170310005850.10808-5-opendmb@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: pgynther@google.com, jaedon.shin@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Doug Berger <opendmb@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170310005850.10808-5-opendmb@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/09/2017 04:58 PM, Doug Berger wrote:
> Since the internal PHY is powered up during the open and resume
> functions it should be powered back down if the functions fail.
> 
> Fixes: 1c1008c793fa ("net: bcmgenet: add main driver file")
> Signed-off-by: Doug Berger <opendmb@gmail.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
