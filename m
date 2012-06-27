From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/7] Get rid of RTA*() macros
Date: Wed, 27 Jun 2012 15:37:03 -0700 (PDT)
Message-ID: <20120627.153703.1027230895828065610.davem@davemloft.net>
References: <cover.1340788373.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47750 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755955Ab2F0WhF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 18:37:05 -0400
In-Reply-To: <cover.1340788373.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Wed, 27 Jun 2012 11:36:09 +0200

> This patchset gets rid of all the RTA_PUT() and RTA_GET()
> macros and makes use of the type-safe netlink API variants
> where applicable.
> 
> I did my best to test these patches but I do not own any
> decnet hardware so the decnet part is compile tested only.

All applied, thanks a lot Thomas.
