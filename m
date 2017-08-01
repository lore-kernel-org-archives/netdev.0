From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v2 06/11] net: dsa: bcm_sf2: remove unneeded
 supported flags
Date: Tue, 1 Aug 2017 14:29:31 -0700
Message-ID: <a5a270a1-2567-4d5e-e047-58ccaa1a37e9@gmail.com>
References: <20170801203241.22294-1-vivien.didelot@savoirfairelinux.com>
 <20170801203241.22294-7-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>, John Crispin <john@phrozen.org>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170801203241.22294-7-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/01/2017 01:32 PM, Vivien Didelot wrote:
> The SF2 driver is masking the supported bitfield of its private copy of
> the ports' ethtool_eee structures. It is used nowhere, thus remove it.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
