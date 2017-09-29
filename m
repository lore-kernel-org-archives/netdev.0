From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 8/8] net: dsa: remove tag ops from the switch
 tree
Date: Fri, 29 Sep 2017 12:20:55 -0700
Message-ID: <b4ba2a1d-23d6-732e-b96b-f808e299b4eb@gmail.com>
References: <20170929183635.8122-1-vivien.didelot@savoirfairelinux.com>
 <20170929183635.8122-9-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170929183635.8122-9-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/29/2017 11:36 AM, Vivien Didelot wrote:
> Now that the dsa_ptr is a dsa_port instance, there is no need to keep
> the tag operations in the dsa_switch_tree structure. Remove it.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
