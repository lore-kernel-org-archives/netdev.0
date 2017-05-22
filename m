From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 05/20] net: dsa: change scope of MDB handlers
Date: Mon, 22 May 2017 12:26:26 -0700
Message-ID: <c631de84-158b-f039-cc2b-12324d79f0e5@gmail.com>
References: <20170519210055.9366-1-vivien.didelot@savoirfairelinux.com>
 <20170519210055.9366-6-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170519210055.9366-6-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/19/2017 02:00 PM, Vivien Didelot wrote:
> Change the scope of the switchdev MDB object handlers from the DSA slave
> device to the generic DSA port, so that the future port-wide API can
> also be used for other port types, such as CPU and DSA links.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
