From: David Miller <davem@davemloft.net>
Subject: all trees merged
Date: Mon, 20 Jun 2011 22:30:54 -0700 (PDT)
Message-ID: <20110620.223054.248100005876325298.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48188 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750965Ab1FUFa5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2011 01:30:57 -0400
Received: from localhost (74-93-104-100-Washington.hfc.comcastbusiness.net [74.93.104.100])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id p5L5UsZG004972
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 20 Jun 2011 22:30:56 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Linus took in my net-2.6 fixes in time for 3.0-rc4

Therefore I fast-forwarded net-2.6 to Linus's tree's head.

Then I merged net-2.6 into net-next-2.6

Note that this makes the staging drivers available in the config by
default as a side effect.
