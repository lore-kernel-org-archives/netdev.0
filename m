From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] IPv4: Send gratuitous ARP for secondary IP
 addresses also
Date: Mon, 25 Jul 2011 16:16:32 -0700 (PDT)
Message-ID: <20110725.161632.432205077107811689.davem@davemloft.net>
References: <1311548970-27522-1-git-send-email-schaman@sch.bme.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: schaman@sch.bme.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46743 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751990Ab1GYXUg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2011 19:20:36 -0400
In-Reply-To: <1311548970-27522-1-git-send-email-schaman@sch.bme.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Zoltan, Kiss" <schaman@sch.bme.hu>
Date: Mon, 25 Jul 2011 01:09:30 +0200

> From: Zoltan Kiss <schaman@sch.bme.hu>
> 
> If a device event generates gratuitous ARP messages, only primary
> address is used for sending. This patch iterates through the whole
> list. Tested with 2 IP addresses configuration on bonding interface.
> 
> Signed-off-by: Zoltan Kiss <schaman@sch.bme.hu>

Applied.
