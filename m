From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 2/9] net: dsa: mv88e6xxx: skip unused ports
Date: Thu, 26 Oct 2017 16:08:16 -0700
Message-ID: <22ab38f3-9357-18e0-d7a4-4f4cdf240b80@gmail.com>
References: <20171026152259.3123-1-vivien.didelot@savoirfairelinux.com>
 <20171026152259.3123-3-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171026152259.3123-3-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/26/2017 08:22 AM, Vivien Didelot wrote:
> The unused ports are currently configured in normal mode. This does not
> prevent the switch from being functional, but it is unnecessary. Skip
> unused ports.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
