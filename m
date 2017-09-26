From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 1/5] net: dsa: return -ENODEV is there is no
 slave PHY
Date: Tue, 26 Sep 2017 14:59:48 -0700
Message-ID: <9c30119d-89b0-468f-926a-e831823a01a6@gmail.com>
References: <20170926211535.21273-1-vivien.didelot@savoirfairelinux.com>
 <20170926211535.21273-2-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170926211535.21273-2-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/26/2017 02:15 PM, Vivien Didelot wrote:
> Instead of returning -EOPNOTSUPP when a slave device has no PHY,
> directly return -ENODEV as ethtool and phylib do.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
--
Florian
