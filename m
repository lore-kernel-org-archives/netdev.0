From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1 linux-next] net/mlx4: use swap() in
 mlx4_init_qp_table()
Date: Thu, 11 Jun 2015 15:21:11 -0700 (PDT)
Message-ID: <20150611.152111.695744254809943489.davem@davemloft.net>
References: <1433953986-24573-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Julia.Lawall@lip6.fr,
	netdev@vger.kernel.org
To: fabf@skynet.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36745 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750834AbbFKWVM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 18:21:12 -0400
In-Reply-To: <1433953986-24573-1-git-send-email-fabf@skynet.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabian Frederick <fabf@skynet.be>
Date: Wed, 10 Jun 2015 18:33:06 +0200

> Use kernel.h macro definition.
> 
> Thanks to Julia Lawall for Coccinelle scripting support.
> 
> Signed-off-by: Fabian Frederick <fabf@skynet.be>

Applied.
