From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v2 1/3] net: dsa: remove useless argument in
 legacy setup
Date: Sun, 6 Aug 2017 10:44:33 -0700
Message-ID: <5890b963-fa6b-4c8c-6831-408c6cac018f@gmail.com>
References: <20170805202019.1679-1-vivien.didelot@savoirfairelinux.com>
 <20170805202019.1679-2-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170805202019.1679-2-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 08/05/2017 01:20 PM, Vivien Didelot wrote:
> dsa_switch_alloc() already assigns ds-dev, which can be used in
> dsa_switch_setup_one and dsa_cpu_dsa_setups instead of requiring an
> additional struct device argument.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
