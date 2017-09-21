From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] net: dsa: add port fdb dump
Date: Wed, 20 Sep 2017 22:09:24 -0700
Message-ID: <ef8cf9d2-4b45-3f49-60b9-c2370fadae01@gmail.com>
References: <20170920233214.6936-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170920233214.6936-1-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 09/20/2017 04:32 PM, Vivien Didelot wrote:
> Dumping a DSA port's FDB entries is not specific to a DSA slave, so add
> a dsa_port_fdb_dump function, similarly to dsa_port_fdb_add and
> dsa_port_fdb_del.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
