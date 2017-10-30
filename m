From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 7/7] net: dsa: remove name arg from slave create
Date: Mon, 30 Oct 2017 11:44:57 -0700
Message-ID: <cf578e41-e882-6cb2-164e-e9650bbec642@gmail.com>
References: <20171027195519.5931-1-vivien.didelot@savoirfairelinux.com>
 <20171027195519.5931-8-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171027195519.5931-8-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/27/2017 12:55 PM, Vivien Didelot wrote:
> Now that slave dsa_port always have their name set, there is no need to
> pass it to dsa_slave_create() anymore. Remove this argument.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
