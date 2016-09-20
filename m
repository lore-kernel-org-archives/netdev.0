From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] net-next: dsa: set_addr should be optional
Date: Tue, 20 Sep 2016 04:48:06 -0400 (EDT)
Message-ID: <20160920.044806.976956241976035160.davem@davemloft.net>
References: <1474291683-44167-1-git-send-email-john@phrozen.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: john@phrozen.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1474291683-44167-1-git-send-email-john@phrozen.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: John Crispin <john@phrozen.org>
Date: Mon, 19 Sep 2016 15:27:59 +0200

> The Marvell driver is the only one that actually sets the switches HW
> address. All other drivers have an empty stub. fix this by making the
> callback optional.

Series applied, thanks.
