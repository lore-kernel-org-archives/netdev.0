From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 4/5] net: dsa: use phy_ethtool_set_link_ksettings
Date: Tue, 26 Sep 2017 15:05:53 -0700
Message-ID: <9f302124-0ddd-c9ad-a7cb-e454f45c9b56@gmail.com>
References: <20170926211535.21273-1-vivien.didelot@savoirfairelinux.com>
 <20170926211535.21273-5-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170926211535.21273-5-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/26/2017 02:15 PM, Vivien Didelot wrote:
> Use phy_ethtool_set_link_ksettings now that dsa_slave_set_link_ksettings
> does exactly the same.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
