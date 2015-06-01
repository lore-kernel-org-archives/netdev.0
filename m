From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] Netfilter fix for net
Date: Mon, 01 Jun 2015 16:57:36 -0700 (PDT)
Message-ID: <20150601.165736.2160584190989701208.davem@davemloft.net>
References: <1433181242-22768-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53637 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752228AbbFAX5i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 19:57:38 -0400
In-Reply-To: <1433181242-22768-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Mon,  1 Jun 2015 19:54:01 +0200

> The following patch reverts the ebtables chunk that enforces counters that was
> introduced in the recently applied d26e2c9ffa38 ('Revert "netfilter: ensure
> number of counters is >0 in do_replace()"') since this breaks ebtables.
> 
> You can pull this change from:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Pulled, thanks Pablo.
