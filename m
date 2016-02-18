From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: bridge: log port STP state on change
Date: Thu, 18 Feb 2016 14:21:10 -0500 (EST)
Message-ID: <20160218.142110.823147456719310558.davem@davemloft.net>
References: <1455635391-25311-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com, idosch@mellanox.com,
	stephen@networkplumber.org, f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455635391-25311-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Tue, 16 Feb 2016 10:09:51 -0500

> Remove the shared br_log_state function and print the info directly in
> br_set_state, where the net_bridge_port state is actually changed.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Applied, thanks Vivien.
