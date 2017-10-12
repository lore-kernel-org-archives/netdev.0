From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 3/5] net: dsa: add slave to port helper
Date: Thu, 12 Oct 2017 15:59:50 -0700
Message-ID: <7c82a8e1-f6fa-df63-0270-4e815d406e0e@gmail.com>
References: <20171012225156.20758-1-vivien.didelot@savoirfairelinux.com>
 <20171012225156.20758-4-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171012225156.20758-4-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/12/2017 03:51 PM, Vivien Didelot wrote:
> Many portions of DSA core code require to get the dsa_port structure
> corresponding to a slave net_device. For this purpose, introduce a
> dsa_slave_to_port() helper.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
