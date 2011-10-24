From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] be2net: fixes
Date: Mon, 24 Oct 2011 18:35:46 -0400 (EDT)
Message-ID: <20111024.183546.495965585975609045.davem@davemloft.net>
References: <1319460303-25560-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51094 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752725Ab1JXWfv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2011 18:35:51 -0400
In-Reply-To: <1319460303-25560-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Mon, 24 Oct 2011 18:14:59 +0530

> Pls apply.
> 
> Sathya Perla (4):
>   be2net: add vlan/rx-mode/flow-control config to be_setup()
>   be2net: refactor VF setup/teardown code into be_vf_setup/clear()
>   be2net: don't create multiple TXQs in BE2
>   be2net: don't create multiple RX/TX rings in multi channel mode

Applied, but many of your commit messages were poorly formatted (lines
exceeding 80 columns) and patches #1 and #2 had several trailing
whitespace errors.

I fixed this all up, but you have to be better than this.
