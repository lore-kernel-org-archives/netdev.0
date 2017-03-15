From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v2 3/3] net: dsa: mv88e6xxx: specify ageing time
 limits
Date: Wed, 15 Mar 2017 13:04:33 -0700
Message-ID: <1c4d818c-6f87-2114-f564-a7bb2db4a187@gmail.com>
References: <20170315195350.11059-1-vivien.didelot@savoirfairelinux.com>
 <20170315195350.11059-4-vivien.didelot@savoirfairelinux.com>
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
In-Reply-To: <20170315195350.11059-4-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/15/2017 12:53 PM, Vivien Didelot wrote:
> Now that DSA has ageing time limits, specify them when registering a
> switch so that out-of-range values are handled correctly by the core.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> Reported-by: Jason Cobham <jcobham@questertangent.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
