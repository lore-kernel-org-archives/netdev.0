From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] drivers/acpi/acpica/utmisc.c: Use printk
 extension %pV
Date: Mon, 19 Jul 2010 22:21:42 -0700
Message-ID: <1279603302.19374.24.camel@Joe-Laptop.home>
References: <1279602367.19374.20.camel@Joe-Laptop.home>
	 <20100719.221630.146073821.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: lenb@kernel.org, linux-acpi@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <20100719.221630.146073821.davem@davemloft.net>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2010-07-19 at 22:16 -0700, David Miller wrote:
> Joe, I really can't keep merging stuff like this into the networking
> tree.

Oh no worries David.

The patch is more like a preliminary notification that at
some point after the vsprintf stuff gets merged into Linus'
tree after 2.6.36-rc1 that this change to acpi could be useful.

> But you're going to have to find another way to merge uses outside of
> networking that you want integrated.

Hey, I'm a patient guy, there's no hurry.

cheers, Joe

