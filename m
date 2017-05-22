From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 03/20] net: dsa: change scope of bridging code
Date: Mon, 22 May 2017 12:24:58 -0700
Message-ID: <f9a597bf-1ed0-4469-db40-1d5e1fd96035@gmail.com>
References: <20170519210055.9366-1-vivien.didelot@savoirfairelinux.com>
 <20170519210055.9366-4-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170519210055.9366-4-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/19/2017 02:00 PM, Vivien Didelot wrote:
> Now that the bridge join and leave functions only deal with a DSA port,
> change their scope from the DSA slave net_device to the DSA generic
> dsa_port.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
