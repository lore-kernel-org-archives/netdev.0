From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH] mlx4: Add support for EEH error recovery
Date: Tue, 24 Jul 2012 00:42:08 +0300
Message-ID: <CAJZOPZKp4su8sOV1Cpm5CG2DYY2xVKUjrSFge5qcYn2pnkC-YA@mail.gmail.com>
References: <500D93F5.4090305@linux.vnet.ibm.com>
	<500DB9CE.5080100@linux.vnet.ibm.com>
	<CAJZOPZJP9OaZVB03kKGtWvrUUb8B--wUNX9z3MG_MNmKr8U3kQ@mail.gmail.com>
	<20120723.143436.2124127996154789223.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: klebers@linux.vnet.ibm.com, ogerlitz@mellanox.com,
	netdev@vger.kernel.org, jackm@dev.mellanox.co.il,
	yevgenyp@mellanox.co.il, cascardo@linux.vnet.ibm.com,
	brking@linux.vnet.ibm.com, shlomop@mellanox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gh0-f174.google.com ([209.85.160.174]:58757 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751820Ab2GWVmJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2012 17:42:09 -0400
Received: by ghrr11 with SMTP id r11so6011901ghr.19
        for <netdev@vger.kernel.org>; Mon, 23 Jul 2012 14:42:08 -0700 (PDT)
In-Reply-To: <20120723.143436.2124127996154789223.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 24, 2012 at 12:34 AM, David Miller <davem@davemloft.net> wrote:

> Can we please move forward, if he implemented the feature properly
> and he tested it successfully, unless you can find a logic or
> stylistic flaw in his patch please ACK it.
>
> You can't hold his changes back while you work out how _YOU_ can
> test it to your liking.

Hi Dave,

We're trying to act in  R/R (Responsive and Responsible) manner -
namely Shlomo did code review of the patches and we want to further
evaluate them by testing, I think its fully legitimate to test a patch
before ACK-ing.  Doing these types of tests isn't around my personal
typical daily menu and I'm asking for some directives from the author
on how to issue that testing, I don't see what wrong here. We're
planning anyway to go deeper around this area and enhance the PCI
hotplug /error handling related code in the driver, so there's an
initial learing curve here, makes sense? we can move the Q&A for the
testing to be off-list if you prefer it to go that way.

Or.
