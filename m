From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/3] netdev/of/phy: MDIO bus multiplexer support.
Date: Thu, 29 Sep 2011 16:31:12 -0400 (EDT)
Message-ID: <20110929.163112.1523715692737597332.davem@davemloft.net>
References: <1317166015-20714-1-git-send-email-david.daney@cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: devicetree-discuss@lists.ozlabs.org, grant.likely@secretlab.ca,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: david.daney@cavium.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1317166015-20714-1-git-send-email-david.daney@cavium.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Daney <david.daney@cavium.com>
Date: Tue, 27 Sep 2011 16:26:52 -0700

> v2: Update bindings to use "reg" and "mdio-parent-bus" insutead of
>     "cell-index" and "parent-bus"

Grant, when the final version of this patch set is ready how do
you want to handle merging it in?

I think it would be safe to merge this via your tree, since the
changes made to existing network driver files are rather trivial and
thus merge conflict friendly.

Actually, I feel like we've discussed this before :-)
