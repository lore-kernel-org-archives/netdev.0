From: Sergej Stepanov <Sergej.Stepanov@ids.de>
Subject: Re: [PATCH 6/9] fs_enet: Be an of_platform device when
	CONFIG_PPC_CPM_NEW_BINDING is set.
Date: Fri, 15 Feb 2008 16:38:56 +0100
Message-ID: <1203089936.20350.7.camel@p60365-ste>
References: <20070920220121.GF28784@loki.buserror.net>
	 <200802151350.20627.laurentp@cse-semaphore.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org, jgarzik@pobox.com
To: Laurent Pinchart <laurentp@cse-semaphore.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ares.ids.de ([213.144.29.131]:59338 "EHLO ares.ids.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750715AbYBOPjA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Feb 2008 10:39:00 -0500
Received: from ares.ids.de (ares.ids.de [127.0.0.1])
	by ares.ids.de (PGP Universal) with ESMTP id 58C72F491A2
	for <netdev@vger.kernel.org>; Fri, 15 Feb 2008 16:38:56 +0100 (CET)
In-Reply-To: <200802151350.20627.laurentp@cse-semaphore.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Am Freitag, den 15.02.2008, 13:50 +0100 schrieb Laurent Pinchart:

> We're loosing the possibility of having MDC and MDIO on different ports. This 
> is quite easy to fix for the non-CONFIG_PPC_CPM_NEW_BINDING case but I'm not 
> familiar with OF bindings (yet) to fix the CONFIG_PPC_CPM_NEW_BINDING case.
> 
for OF issue i had this for a paar month:
http://www.spinics.net/lists/netdev/msg45778.html
http://www.spinics.net/lists/netdev/msg47159.html
i'll be glad if it helps...

Regards
Sergej.


