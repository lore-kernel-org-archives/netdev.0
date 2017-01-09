From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] net: dsa: select NET_SWITCHDEV
Date: Sun, 8 Jan 2017 17:18:44 -0800
Message-ID: <ae5c2999-98a3-1b88-dd1d-970d958f6d7a@gmail.com>
References: <20170108231724.27398-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>, Jiri Pirko <jiri@resnulli.us>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170108231724.27398-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/08/2017 03:17 PM, Vivien Didelot wrote:
> DSA wraps SWITCHDEV, thus select it instead of depending on it.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
