From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: bridge: fix br_stp_enable_bridge comment
Date: Mon, 25 Jul 2016 10:31:26 -0700 (PDT)
Message-ID: <20160725.103126.2008768648930371158.davem@davemloft.net>
References: <20160721164210.26662-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com, stephen@networkplumber.org
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160721164210.26662-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Thu, 21 Jul 2016 12:42:10 -0400

> br_stp_enable_bridge() does take the br->lock spinlock. Fix its wrongly
> pasted comment and use the same as br_stp_disable_bridge().
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Applied.
