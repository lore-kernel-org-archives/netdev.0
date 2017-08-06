From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v2 2/3] net: dsa: remove useless args of
 dsa_cpu_dsa_setup
Date: Sun, 6 Aug 2017 10:45:35 -0700
Message-ID: <48cd4eaf-3be0-f213-8d63-40788dd885f8@gmail.com>
References: <20170805202019.1679-1-vivien.didelot@savoirfairelinux.com>
 <20170805202019.1679-3-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170805202019.1679-3-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 08/05/2017 01:20 PM, Vivien Didelot wrote:
> dsa_cpu_dsa_setup currently takes 4 arguments but they are all available
> from the dsa_port argument. Remove all others.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
