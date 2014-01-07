From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 1/3] ipv4: introduce ip_dst_mtu_secure and
 protect forwarding path against pmtu spoofing
Date: Mon, 06 Jan 2014 19:42:03 -0500 (EST)
Message-ID: <20140106.194203.1057131663158804667.davem@davemloft.net>
References: <20140106084827.GA5766@order.stressinduktion.org>
	<20140106.160846.544525591241855516.davem@davemloft.net>
	<20140107001103.GE10204@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	johnwheffner@gmail.com, steffen.klassert@secunet.com,
	fweimer@redhat.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36433 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754620AbaAGAmH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 19:42:07 -0500
In-Reply-To: <20140107001103.GE10204@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Tue, 7 Jan 2014 01:11:03 +0100

> Have you seen that Steffen did test these patches with his pmtu
> testsuite successfully and they showed no obvious regressions (he
> posted to the old thread)?

Yes I saw that.
