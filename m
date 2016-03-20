From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1 0/2] basic ioctl support for netlink sockets
Date: Sun, 20 Mar 2016 13:31:22 -0400 (EDT)
Message-ID: <20160320.133122.908035685889835834.davem@davemloft.net>
References: <1458259436-85275-1-git-send-email-ddecotig@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	nikolay@cumulusnetworks.com, mst@redhat.com, ben@decadent.org.uk,
	jeffrey.t.kirsher@intel.com, decot@googlers.com,
	nicolas.dichtel@6wind.com, andrew@lunn.ch, hadarh@mellanox.com,
	ecree@solarflare.com, john.r.fastabend@intel.com,
	herbert@gondor.apana.org.au, tgraf@suug.ch, daniel@iogearbox.net,
	chamaken@gmail.com, fw@strlen.de, dh.herrmann@gmail.com
To: ddecotig@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1458259436-85275-1-git-send-email-ddecotig@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Decotigny <ddecotig@gmail.com>
Date: Thu, 17 Mar 2016 17:03:54 -0700

> This removes the requirement that ethtool be tied to the support
> of a specific L3 protocol, also updates a comment.

You're adding an ioctl handler to netlink sockets, and it is not
at all apparent to me how this influences ethtool handling at all.

Therefore you have to explain this here and in your commit message.
