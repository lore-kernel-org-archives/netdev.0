From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V7 2/4 net-next] skbuff: Add userspace zero-copy
 buffers in skb
Date: Mon, 27 Jun 2011 15:54:26 -0700 (PDT)
Message-ID: <20110627.155426.51839633424542723.davem@davemloft.net>
References: <1306610588.5180.87.camel@localhost.localdomain>
	<1309189510.21764.1.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, eric.dumazet@gmail.com, avi@redhat.com,
	arnd@arndb.de, netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: mashirle@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39873 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755262Ab1F0Wye (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2011 18:54:34 -0400
In-Reply-To: <1309189510.21764.1.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shirley Ma <mashirle@us.ibm.com>
Date: Mon, 27 Jun 2011 08:45:10 -0700

> To support skb zero-copy, a pointer is needed to add to skb share info.
> Do you agree with this approach? If not, do you have any other
> suggestions?

I really can't form an opinion unless I am shown the complete
implementation, what this give us in return, what the impact is, etc.
