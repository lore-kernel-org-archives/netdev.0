From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 04/11] ipv6: move route updating for redirect to ndisc
 layer
Date: Thu, 12 Sep 2013 15:03:52 -0400 (EDT)
Message-ID: <20130912.150352.648884854025469937.davem@davemloft.net>
References: <52319A6E.6090503@cn.fujitsu.com>
	<52319B99.6090303@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: duanj.fnst@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36803 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753406Ab3ILTD5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Sep 2013 15:03:57 -0400
In-Reply-To: <52319B99.6090303@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It is completely pointless to use the same exact subject line for
several patches in a patch set.

You absolutely must choose unique subject line text for each patch so
that someone skimming the shortlog can tell what might be unique to
each patch.
