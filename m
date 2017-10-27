From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 5/9] net: dsa: use dsa_is_user_port everywhere
Date: Thu, 26 Oct 2017 17:15:24 -0700
Message-ID: <35970ef4-83ff-4367-87e3-ed003cd9857d@gmail.com>
References: <20171026152259.3123-1-vivien.didelot@savoirfairelinux.com>
 <20171026152259.3123-6-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171026152259.3123-6-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/26/2017 08:22 AM, Vivien Didelot wrote:
> Most of the DSA code still check ds->enabled_port_mask directly to
> inspect a given port type instead of using the provided dsa_is_user_port
> helper. Change this.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
