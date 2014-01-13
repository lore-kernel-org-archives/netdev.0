From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 0/3] path mtu hardening patches
Date: Mon, 13 Jan 2014 11:25:04 -0800 (PST)
Message-ID: <20140113.112504.922587457597727366.davem@davemloft.net>
References: <1389258077-23282-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	johnwheffner@gmail.com, steffen.klassert@secunet.com,
	fweimer@redhat.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38026 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752379AbaAMTZF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 14:25:05 -0500
In-Reply-To: <1389258077-23282-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: hannes@stressinduktion.org
Date: Thu,  9 Jan 2014 10:01:14 +0100

> After a lot of back and forth I want to propose these changes regarding
> path mtu hardening and give an outline why I think this is the best way
> how to proceed:

I'm not going to fight this any more even though I still disagree with
these changes.  John Heffner has not provided a coherent strong
argument for not doing this, in fact the counter arguments were
extremely vague.

I am pretty sure that now my worst fears will be realized and every
single distribution will not use the kernel's default, and everyone
will get this behavior rather than adminstrators making well informed
decisions about how to defend against these kind of situations when
enabling routing, or whether they'd even be exposed to the issue at
all in a particular setup.

Such is life.
