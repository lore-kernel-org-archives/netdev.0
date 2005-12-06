From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Broadcom 43xx first results
Date: Tue, 06 Dec 2005 15:25:05 -0800 (PST)
Message-ID: <20051206.152505.71096177.davem@davemloft.net>
References: <20051205211107.61941ab9@griffin.suse.cz>
	<20051206150909.GB1999@elf.ucw.cz>
	<4395BFBB.8060304@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pavel@suse.cz, jbenc@suse.cz, hch@infradead.org, josejx@gentoo.org,
	mbuesch@freenet.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030285AbVLFXZK@vger.kernel.org>
To: greearb@candelatech.com
In-Reply-To: <4395BFBB.8060304@candelatech.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Greear <greearb@candelatech.com>
Date: Tue, 06 Dec 2005 08:43:39 -0800

> Merge now even if it breaks the current tree?

DCCP is a good counter example, zero --> some functionality is
always preferred.  Our DCCP stack is far from being finished, but
it is in there and getting polished and maintained like everything
else in the upstream tree.

And once it's in there, we can review small patches that add new
functionality not this behemouth "here's the whole thing" jumbo
patch that nobody will want to review.
