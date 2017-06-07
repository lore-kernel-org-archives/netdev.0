From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 1/5] net: dsa: mv88e6xxx: define membership on
 VLAN add
Date: Wed, 7 Jun 2017 12:31:46 -0700
Message-ID: <f4c5f796-9379-c43a-767c-71f12f8b414c@gmail.com>
References: <20170606205631.22880-1-vivien.didelot@savoirfairelinux.com>
 <20170606205631.22880-2-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170606205631.22880-2-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/06/2017 01:56 PM, Vivien Didelot wrote:
> Define the target port membership of the VLAN entry in
> mv88e6xxx_port_vlan_add where ds is scoped.
> 
> Allow the DSA core to call later the port_vlan_add operation for CPU or
> DSA ports, by using the Unmodified membership for these ports, as in the
> current behavior.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
