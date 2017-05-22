From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 20/20] net: dsa: add VLAN notifier
Date: Mon, 22 May 2017 12:41:59 -0700
Message-ID: <8624a425-a847-4896-58d1-9caba22f2cfd@gmail.com>
References: <20170519210055.9366-1-vivien.didelot@savoirfairelinux.com>
 <20170519210055.9366-21-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170519210055.9366-21-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/19/2017 02:00 PM, Vivien Didelot wrote:
> Add two new DSA_NOTIFIER_VLAN_ADD and DSA_NOTIFIER_VLAN_DEL events to
> notify not only a single switch, but all switches of a the fabric when
> an VLAN entry is added or removed.
> 
> For the moment, keep the current behavior and ignore other switches.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
