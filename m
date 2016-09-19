From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 0/4] net-next: dsa: set_addr should be optional
Date: Mon, 19 Sep 2016 15:45:48 +0200
Message-ID: <20160919134548.GB8651@lunn.ch>
References: <1474291683-44167-1-git-send-email-john@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: John Crispin <john@phrozen.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1474291683-44167-1-git-send-email-john@phrozen.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 19, 2016 at 03:27:59PM +0200, John Crispin wrote:
> The Marvell driver is the only one that actually sets the switches HW
> address. All other drivers have an empty stub. fix this by making the
> callback optional.

Hi John

Thanks for doing this,

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
