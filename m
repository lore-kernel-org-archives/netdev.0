From: jamal <hadi@cyberus.ca>
Subject: Re: Fwd: [PATCH] [-mm] ACPI: export ACPI events via netlink
Date: Fri, 15 Jun 2007 06:26:50 -0400
Message-ID: <1181903210.4102.7.camel@localhost>
References: <1179827251.7707.29.camel@localhost.localdomain>
	 <1179831825.4121.30.camel@localhost>
	 <1180258853.7707.53.camel@localhost.localdomain>
	 <4466a10705270629h31977813hd2fc8330bcd87f78@mail.gmail.com>
	 <4466a10705270634j3560c9a3j9c3630ddc20a24aa@mail.gmail.com>
	 <1181811576.5411.27.camel@localhost.localdomain>
	 <1181820510.4091.9.camel@localhost>
	 <1181869285.5411.39.camel@localhost.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"linux-acpi@vger" <linux-acpi@vger.kernel.org>, lenb@kernel.org
To: Zhang Rui <rui.zhang@intel.com>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <1181869285.5411.39.camel@localhost.localdomain>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-15-06 at 09:01 +0800, Zhang Rui wrote:

> > rtnl_open_byproto(&rth, nl_mgrp(mydiscoveredacpiid), NETLINK_GENERIC)
> > 
> Yes. It doesn't work if I use my group id here.
> In fact, I'm using rtnl_open_byproto(&rth, 1, NETLINK_GENERIC) now.
> That's why I said that this demo receives all the broadcasted genetlink
> messages.

Ok, tell me how to generate these ACPI events and i will patch my laptop
and test it. What kernel compile options do i need? 2.6.24-rc4 will do?

cheers,
jamal

