From: David Miller <davem@davemloft.net>
Subject: Re: qdisc requeue stats
Date: Fri, 26 Dec 2008 14:29:23 -0800 (PST)
Message-ID: <20081226.142923.63754891.davem@davemloft.net>
References: <be9d10f20812261414n30d8061bkf2af90d3cbca8e95@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: donash4@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52811
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751292AbYLZW3V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Dec 2008 17:29:21 -0500
In-Reply-To: <be9d10f20812261414n30d8061bkf2af90d3cbca8e95@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Don Ash" <donash4@gmail.com>
Date: Sat, 27 Dec 2008 00:14:03 +0200

> Is there a way to see q->qstats.requeues statistics
> (dev_requeue_skb()) ? I tried tc tool but it does not
> show it...

You'll have better luck with this question on the networking
developer list, which has been added to the CC:
