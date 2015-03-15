From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/3] switchdev: support stp updates on
 stacked netdevices
Date: Sun, 15 Mar 2015 18:32:13 -0400 (EDT)
Message-ID: <20150315.183213.1225773184212277874.davem@davemloft.net>
References: <20150313.123156.2118585119289960334.davem@davemloft.net>
	<CAE4R7bCvFPE5nPBJ7r41-ZC6=5AUE=gQ7uTy4kTNTZf-xKraVg@mail.gmail.com>
	<20150315191722.GE3518@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfeldma@gmail.com, roopa@cumulusnetworks.com,
	netdev@vger.kernel.org
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51245 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751296AbbCOWcP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 18:32:15 -0400
In-Reply-To: <20150315191722.GE3518@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Sun, 15 Mar 2015 20:17:22 +0100

> Does that make sense? I think it is better just pick what we want to
> support now and implement it there. That makes things clearer and
> confusion-prone.

You can't even say whether it makes sense or not, you yourself
even have to ask.

Again, I don't want to design our interfaces for potential needs,
I want to design them for actually known needs.

We'll deal with the discovered exceptions on an as-needed basis,
not from the beginning.
