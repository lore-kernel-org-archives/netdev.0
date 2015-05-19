From: David Miller <davem@davemloft.net>
Subject: Re: Default XPS settings in mlx4 driver
Date: Tue, 19 May 2015 16:49:33 -0400 (EDT)
Message-ID: <20150519.164933.532669496755991434.davem@davemloft.net>
References: <CALx6S36qXcqhfFQVLWu2CgoJYQL6E-myvgBvDFxATA+NjX+qBA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: idos@mellanox.com, amirv@mellanox.com, netdev@vger.kernel.org
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48045 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750750AbbESUtf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 16:49:35 -0400
In-Reply-To: <CALx6S36qXcqhfFQVLWu2CgoJYQL6E-myvgBvDFxATA+NjX+qBA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Tue, 19 May 2015 13:38:35 -0700

> Looks like there's a few other drivers that are setting XPS, they
> might have similar issue.

We really need generic infrastructure for such configuration attempts
so that the default policy across all such drivers is consistent.
