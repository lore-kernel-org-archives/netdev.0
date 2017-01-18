From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 1/2] net: dsa: store CPU switch structure in the
 tree
Date: Wed, 18 Jan 2017 12:35:23 -0800
Message-ID: <aefbb268-ea4c-241c-341a-fd9ce4062715@gmail.com>
References: <20170118014139.31417-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170118014139.31417-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/17/2017 05:41 PM, Vivien Didelot wrote:
> Store a dsa_switch pointer to the CPU switch in the tree instead of only
> its index. This avoids the need to initialize it to -1.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
