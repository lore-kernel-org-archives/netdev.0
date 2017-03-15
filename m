From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v2 1/3] net: dsa: dsa_fastest_ageing_time return
 unsigned
Date: Wed, 15 Mar 2017 13:03:20 -0700
Message-ID: <4d14cb94-9d51-e2a8-d17e-7f2ef845ff1b@gmail.com>
References: <20170315195350.11059-1-vivien.didelot@savoirfairelinux.com>
 <20170315195350.11059-2-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Jason Cobham <jcobham@questertangent.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170315195350.11059-2-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/15/2017 12:53 PM, Vivien Didelot wrote:
> The ageing time is defined as unsigned int, so make
> dsa_fastest_ageing_time return an unsigned int instead of int.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
