From: David Miller <davem@davemloft.net>
Subject: Re: [B.A.T.M.A.N.] pull request: batman-adv 2012-04-11
Date: Wed, 11 Apr 2012 10:39:33 -0400 (EDT)
Message-ID: <20120411.103933.846397076858317541.davem@davemloft.net>
References: <20120411130301.GD19365@ritirata.org>
	<20120411.095809.861355939666821335.davem@davemloft.net>
	<20120411143102.GE19365@ritirata.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: ordex@autistici.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54643 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754622Ab2DKOlo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Apr 2012 10:41:44 -0400
In-Reply-To: <20120411143102.GE19365@ritirata.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <ordex@autistici.org>
Date: Wed, 11 Apr 2012 16:31:03 +0200

> Actually we have either the Kconfig option (for binary size purposes) AND a
> boolean attribute in our soft_interface sysfs path (to dynamically turn the
> bridge loop avoidance ON and OFF as you were suggesting).

Distributions are just going to turn on everything, so for %99.999 of
users you really aren't saving anything.
