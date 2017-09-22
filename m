From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 4/4] net: dsa: add port enable and disable
 helpers
Date: Fri, 22 Sep 2017 10:16:35 -0700
Message-ID: <23727dc0-e9e4-2353-7cf2-92a31b6cbb7a@gmail.com>
References: <20170922161753.19563-1-vivien.didelot@savoirfairelinux.com>
 <20170922161753.19563-5-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170922161753.19563-5-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/22/2017 09:17 AM, Vivien Didelot wrote:
> Provide dsa_port_enable and dsa_port_disable helpers to respectively
> enable and disable a switch port. This makes the dsa_port_set_state_now
> helper static.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
