From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [PATCH 3/3] e1000e: add support for new 82574L part
Date: Tue, 12 Aug 2008 18:37:03 +0200
Message-ID: <200808121837.03714.netdev@axxeo.de>
References: <20080811223538.10443.93381.stgit@localhost.localdomain> <20080811223552.10443.82532.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, akpm@linux-foundation.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:46674 "EHLO mail.axxeo.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751227AbYHLQhX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Aug 2008 12:37:23 -0400
In-Reply-To: <20080811223552.10443.82532.stgit@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jeff,

you have unresolved merge conflicts in your patch, please resolve them first.

Jeff Kirsher schrieb:
> +<<<<<<< HEAD:drivers/net/e1000e/netdev.c
> +=======
> +>>>>>>> 909d1be8144df3854741a9e3e8cae93d8d88a16c:drivers/net/e1000e/netdev.c
> +<<<<<<< HEAD:drivers/net/e1000e/netdev.c
> +=======
> +>>>>>>> 909d1be8144df3854741a9e3e8cae93d8d88a16c:drivers/net/e1000e/netdev.c
> +<<<<<<< HEAD:drivers/net/e1000e/netdev.c
> +=======
> +>>>>>>> 909d1be8144df3854741a9e3e8cae93d8d88a16c:drivers/net/e1000e/netdev.c
> +<<<<<<< HEAD:drivers/net/e1000e/netdev.c
> +=======
> +>>>>>>> 909d1be8144df3854741a9e3e8cae93d8d88a16c:drivers/net/e1000e/netdev.c
> +<<<<<<< HEAD:drivers/net/e1000e/netdev.c
> +=======
> +>>>>>>> 909d1be8144df3854741a9e3e8cae93d8d88a16c:drivers/net/e1000e/netdev.c


Just search in your editor for these marks in the patch you sent and resolve these 
in your repository.


Best Regards

Ingo Oeser
