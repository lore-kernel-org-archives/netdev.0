From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] cls_cgroup: unify classid syntax to tc
Date: Thu, 11 Jun 2009 02:13:47 -0700 (PDT)
Message-ID: <20090611.021347.142243970.davem@davemloft.net>
References: <20090611180555.f2c76568.usui@mxm.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: containers@lists.linux-foundation.org, netdev@vger.kernel.org,
	tgraf@suug.ch, hadi@cyberus.ca, jarkao2@gmail.com
To: usui@mxm.nes.nec.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38875
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752994AbZFKJNp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 05:13:45 -0400
In-Reply-To: <20090611180555.f2c76568.usui@mxm.nes.nec.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Minoru Usui <usui@mxm.nes.nec.co.jp>
Date: Thu, 11 Jun 2009 18:05:55 +0900

> This patch unifies classid syntax of cls_cgroup to tc.

Won't this break existing users?

We really can't say "oh sorry" and change things after it's
been effectively deployed already.
