From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH v2 0/3] netdev/of/phy: MDIO bus multiplexer support.
Date: Thu, 29 Sep 2011 18:32:14 -0600
Message-ID: <20110930003214.GB12606@ponder.secretlab.ca>
References: <1317166015-20714-1-git-send-email-david.daney@cavium.com>
 <20110929.163112.1523715692737597332.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: david.daney@cavium.com, devicetree-discuss@lists.ozlabs.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110929.163112.1523715692737597332.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 29, 2011 at 04:31:12PM -0400, David Miller wrote:
> From: David Daney <david.daney@cavium.com>
> Date: Tue, 27 Sep 2011 16:26:52 -0700
> 
> > v2: Update bindings to use "reg" and "mdio-parent-bus" insutead of
> >     "cell-index" and "parent-bus"
> 
> Grant, when the final version of this patch set is ready how do
> you want to handle merging it in?
> 
> I think it would be safe to merge this via your tree, since the
> changes made to existing network driver files are rather trivial and
> thus merge conflict friendly.

Your tree or mine, I'm happy either way.  Even if there were
conflicts, they would be trivial.

Sure, I'll take care of merging it when I see an ack from you.

> Actually, I feel like we've discussed this before :-)

:)

g.
