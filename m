From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 1/3] ipv4: introduce ip_dst_mtu_secure and
 protect forwarding path against pmtu spoofing
Date: Wed, 08 Jan 2014 01:49:40 -0500 (EST)
Message-ID: <20140108.014940.1139765295618203197.davem@davemloft.net>
References: <20140108050225.GO30393@order.stressinduktion.org>
	<20140108.010213.884915830982848289.davem@davemloft.net>
	<20140108061320.GA9007@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	johnwheffner@gmail.com, steffen.klassert@secunet.com,
	fweimer@redhat.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47999 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753753AbaAHGto (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 01:49:44 -0500
In-Reply-To: <20140108061320.GA9007@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Wed, 8 Jan 2014 07:13:20 +0100

> I am sorry..  maybe I am just stupid?

I thought I was clear about wanting the new behavior to _NOT_ be the
default.  I thought we agreed on this.
