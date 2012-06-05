From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 0/5] gianfar: coding style cleanups
Date: Tue, 05 Jun 2012 15:38:57 -0700 (PDT)
Message-ID: <20120605.153857.377350943833154743.davem@davemloft.net>
References: <1338903735-24527-1-git-send-email-jan.ceuleers@computer.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: b06378@freescale.com, joe@perches.com, netdev@vger.kernel.org
To: jan.ceuleers@computer.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58997 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750764Ab2FEWi7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2012 18:38:59 -0400
In-Reply-To: <1338903735-24527-1-git-send-email-jan.ceuleers@computer.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Ceuleers <jan.ceuleers@computer.org>
Date: Tue,  5 Jun 2012 15:42:10 +0200

> Various coding style cleanups, mostly whitespace and comment reformatting.
> 
> I have left a number of lines untouched where I felt that the changes I
> was considering were not improving readability. But de gustibus etc.
> 
> Patch 4/5 also removes some superfluous local variable initialisations.
> These are obviously correct because the variable is initialised again
> right after. But you might consider this to be unnecessary code churn
> because the compiler is unlikely to generate better code due to this patch.
> 
> WARNING: Compile-tested only. I do not have the hardware.

All applied, thanks Jan.
