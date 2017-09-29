From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 5/8] net: dsa: add tagging ops to port
Date: Fri, 29 Sep 2017 12:12:53 -0700
Message-ID: <ce388931-3303-77e0-66a3-9bb8d8651ea4@gmail.com>
References: <20170929183635.8122-1-vivien.didelot@savoirfairelinux.com>
 <20170929183635.8122-6-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170929183635.8122-6-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/29/2017 11:36 AM, Vivien Didelot wrote:
> The DSA tagging protocol operations are specific to each CPU port,
> thus the dsa_device_ops pointer belongs to the dsa_port structure.
> 
> From now on assign a slave's xmit copy from its CPU port tagging
> operations. This will ease the future support for multiple CPU ports.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
