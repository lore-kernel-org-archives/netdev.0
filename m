From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/3] Implementation of RFC 4898 Extended TCP
 Statistics (Web10G)
Date: Tue, 16 Dec 2014 14:09:19 -0500 (EST)
Message-ID: <20141216.140919.44020047339373813.davem@davemloft.net>
References: <CAADnVQ+rmBMoDRRu-Dtp7QBMJEbto9nb2zvFEXBCQsqpg6tS9A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rapier@psc.edu, netdev@vger.kernel.org
To: alexei.starovoitov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54987 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750882AbaLPTJY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2014 14:09:24 -0500
In-Reply-To: <CAADnVQ+rmBMoDRRu-Dtp7QBMJEbto9nb2zvFEXBCQsqpg6tS9A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Date: Tue, 16 Dec 2014 10:24:31 -0800

> imo that is very questionable design choice.
> export a lot of in-kernel bits to be used by out-of-tree kernel module?

It's a non-starter.
