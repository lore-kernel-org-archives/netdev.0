From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 1/4] net-next: dsa: fix duplicate invocation of set_addr()
Date: Mon, 19 Sep 2016 15:44:03 +0200
Message-ID: <20160919134403.GA8651@lunn.ch>
References: <1474291683-44167-1-git-send-email-john@phrozen.org>
 <1474291683-44167-2-git-send-email-john@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: John Crispin <john@phrozen.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1474291683-44167-2-git-send-email-john@phrozen.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 19, 2016 at 03:28:00PM +0200, John Crispin wrote:
> commit 83c0afaec7b730b ("net: dsa: Add new binding implementation")
> has a duplicate invocation of the set_addr() operation callback. Remove one
> of them.

Upps. My error...

> 
> Signed-off-by: John Crispin <john@phrozen.org>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
