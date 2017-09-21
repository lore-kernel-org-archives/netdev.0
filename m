From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] net: dsa: better scoping of slave functions
Date: Wed, 20 Sep 2017 22:08:48 -0700
Message-ID: <46cc1707-2b30-c258-dafc-7393b97d5b0e@gmail.com>
References: <20170920233157.6832-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170920233157.6832-1-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 09/20/2017 04:31 PM, Vivien Didelot wrote:
> A few DSA slave functions take a dsa_slave_priv pointer as first
> argument, whereas the scope of the slave.c functions is the slave
> net_device structure. Fix this and rename dsa_netpoll_send_skb to
> dsa_slave_netpoll_send_skb.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
