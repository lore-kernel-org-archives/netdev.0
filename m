From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] net: phy: fix of_node and device leaks
Date: Thu, 17 Nov 2016 12:05:50 -0500 (EST)
Message-ID: <20161117.120550.24158862253694255.davem@davemloft.net>
References: <1479306038-27211-1-git-send-email-johan@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, robh+dt@kernel.org, frowand.list@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: johan@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1479306038-27211-1-git-send-email-johan@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Johan Hovold <johan@kernel.org>
Date: Wed, 16 Nov 2016 15:20:35 +0100

> These patches fix a couple of of_node leaks in the fixed-link code and a
> device reference leak in a phy helper.

Series applied, thanks.
