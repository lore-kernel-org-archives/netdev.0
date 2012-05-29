From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r6040: disable pci device if the subsequent calls
 (after pci_enable_device) fails
Date: Tue, 29 May 2012 19:18:10 -0400 (EDT)
Message-ID: <20120529.191810.2141710455829509698.davem@davemloft.net>
References: <1338333250-11974-1-git-send-email-devendra.aaru@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: florian@openwrt.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: devendra.aaru@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1338333250-11974-1-git-send-email-devendra.aaru@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Please number your patches so that there is no ambguity as to what
order the patches should be applied.

That is especially important for patches like these two which make
changes in the same areas of code.
