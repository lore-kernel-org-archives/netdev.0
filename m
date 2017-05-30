From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: b53: remove unused dev argument
Date: Mon, 29 May 2017 23:35:02 -0400 (EDT)
Message-ID: <20170529.233502.272236772394101896.davem@davemloft.net>
References: <20170526220737.24579-1-vivien.didelot@savoirfairelinux.com>
        <d6ae6f6b-2afd-95dc-d14a-82187ac64400@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vivien.didelot@savoirfairelinux.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        andrew@lunn.ch
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <d6ae6f6b-2afd-95dc-d14a-82187ac64400@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Fri, 26 May 2017 15:50:51 -0700

> On 05/26/2017 03:07 PM, Vivien Didelot wrote:
>> The port net device passed to b53_fdb_copy is not used. Remove it.
>> 
>> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> 
> Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

Applied.
