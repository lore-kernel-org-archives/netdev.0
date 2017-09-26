From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/2] net: dsa: port enabling
Date: Mon, 25 Sep 2017 20:23:48 -0700 (PDT)
Message-ID: <20170925.202348.427280980077958763.davem@davemloft.net>
References: <20170922230156.19521-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170922230156.19521-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Fri, 22 Sep 2017 19:01:54 -0400

> This patchset makes slave open and close symmetrical and provides
> helpers for enabling or disabling a given DSA port.
> 
> Changes in v3:
>   - save the phy_device change for a future patchset
> 
> Changes in v2:
>   - do not remove the phy argument from port enable/disable

Series applied.
