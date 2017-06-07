From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 4/5] net: dsa: mv88e6xxx: exclude all ports in
 new VLAN
Date: Wed, 7 Jun 2017 12:34:35 -0700
Message-ID: <76c1c68b-466c-f0cc-edbf-324445064650@gmail.com>
References: <20170606205631.22880-1-vivien.didelot@savoirfairelinux.com>
 <20170606205631.22880-5-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170606205631.22880-5-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/06/2017 01:56 PM, Vivien Didelot wrote:
> Now that the DSA core adds the CPU and DSA ports itself to the new VLAN
> entry, there is no need to include them as members of this VLAN when
> initializing a new VTU entry.
> 
> As of now, initialize a new VTU entry with all ports excluded.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
