From: David Miller <davem@davemloft.net>
Subject: Re: [patch] sock_diag: off by one checks
Date: Thu, 08 Dec 2011 19:54:52 -0500 (EST)
Message-ID: <20111208.195452.1335073462061460670.davem@davemloft.net>
References: <20111208064938.GB16735@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@parallels.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35678 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752792Ab1LIAy6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2011 19:54:58 -0500
In-Reply-To: <20111208064938.GB16735@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 8 Dec 2011 09:49:38 +0300

> These tests are off by one because sock_diag_handlers[] only has AF_MAX
> elements.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
