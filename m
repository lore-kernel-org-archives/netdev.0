From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: PCI interrupt problem: e1000 & Super-Micro X6DVA motherboard
Date: Thu, 24 Mar 2005 09:10:03 +0100
Message-ID: <20050324081003.GA23453@xi.wantstofly.org>
References: <42421FF2.7050501@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Content-Disposition: inline
In-Reply-To: <42421FF2.7050501@candelatech.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 23, 2005 at 06:03:30PM -0800, Ben Greear wrote:

> I have two 4-port e1000 NICs in the system, on a riser card.

How is the riser card wired?  F.e. does it have a single edge
connector, and provides two PCI slots, or does it have a tiny
additional edge connector that routes REQ#/GNT#/INTx from a
nearby PCI slot, etc.?


--L
