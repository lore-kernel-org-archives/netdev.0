From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/3] net: dsa: remove useless arguments
Date: Mon, 07 Aug 2017 14:24:37 -0700 (PDT)
Message-ID: <20170807.142437.1790018700462135738.davem@davemloft.net>
References: <20170805202019.1679-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170805202019.1679-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Sat,  5 Aug 2017 16:20:16 -0400

> Several DSA core setup functions take many arguments, mostly because of
> the legacy code. This patch series removes the useless args of these
> functions, where either the dsa_switch or dsa_port argument is enough.
> 
> Changes in v2:
>   - ds->dev is already assigned by dsa_switch_alloc

Series applied, thanks.
