From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 6/7] net: dsa: get port name at parse time
Date: Mon, 30 Oct 2017 11:44:38 -0700
Message-ID: <4d505a53-9a2f-3048-4fcc-d1ef0a98f523@gmail.com>
References: <20171027195519.5931-1-vivien.didelot@savoirfairelinux.com>
 <20171027195519.5931-7-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171027195519.5931-7-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/27/2017 12:55 PM, Vivien Didelot wrote:
> Get the optional "label" property and assign a default one directly at
> parse time instead of doing it when creating the slave.
> 
> For legacy, simply assign the port name stored in cd->port_names.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
