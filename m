From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/3] net: dsa: push switchdev prepare phase
 in FDB ops
Date: Sun, 11 Oct 2015 05:29:18 -0700 (PDT)
Message-ID: <20151011.052918.2192337764291176285.davem@davemloft.net>
References: <1444318514-32250-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com, sfeldma@gmail.com, jiri@resnulli.us,
	f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444318514-32250-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Thu,  8 Oct 2015 11:35:11 -0400

> This patchset pushes the switchdev prepare phase for the FDB add and del
> operations down to the DSA drivers. Currently only mv88e6xxx is affected.
> 
> Since the dump requires a bit of refactoring in the driver, it'll come in a
> future patchset.
> 
> Changes in v2:
>  * forward declare switchdev structs instead of fixing the dsa.h include.

Series applied, thanks.
