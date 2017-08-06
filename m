From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v2 3/3] net: dsa: remove useless args of
 dsa_slave_create
Date: Sun, 6 Aug 2017 10:46:39 -0700
Message-ID: <05f2e3a8-3717-d1ae-683c-da266bbc671d@gmail.com>
References: <20170805202019.1679-1-vivien.didelot@savoirfairelinux.com>
 <20170805202019.1679-4-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170805202019.1679-4-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 08/05/2017 01:20 PM, Vivien Didelot wrote:
> dsa_slave_create currently takes 4 arguments while it only needs the
> related dsa_port and its name. Remove all other arguments.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
