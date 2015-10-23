From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: mv88e6xxx: remove debugfs interface
Date: Thu, 22 Oct 2015 19:17:59 -0700 (PDT)
Message-ID: <20151022.191759.1117601118927909154.davem@davemloft.net>
References: <1445547271-28003-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com, andrew@lunn.ch, sfeldma@gmail.com
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445547271-28003-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Thu, 22 Oct 2015 16:54:31 -0400

> It is preferable to have a common debugfs interface for DSA or switchdev
> instead of a driver specific one. Thus remove the mv88e6xxx debug code.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Applied, thanks.
