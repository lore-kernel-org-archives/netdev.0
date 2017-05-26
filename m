From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] net: dsa: b53: remove unused dev argument
Date: Fri, 26 May 2017 15:50:51 -0700
Message-ID: <d6ae6f6b-2afd-95dc-d14a-82187ac64400@gmail.com>
References: <20170526220737.24579-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170526220737.24579-1-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/26/2017 03:07 PM, Vivien Didelot wrote:
> The port net device passed to b53_fdb_copy is not used. Remove it.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
