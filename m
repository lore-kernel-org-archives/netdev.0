From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] gianfar: Make multi-queue polling optional
Date: Fri, 07 Mar 2014 13:20:45 -0500 (EST)
Message-ID: <20140307.132045.89928137635289175.davem@davemloft.net>
References: <1394008119-27899-3-git-send-email-claudiu.manoil@freescale.com>
	<20140306.165236.1656673150420499957.davem@davemloft.net>
	<5319C110.2060901@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: claudiu.manoil@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42399 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753090AbaCGSUr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2014 13:20:47 -0500
In-Reply-To: <5319C110.2060901@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Claudiu Manoil <claudiu.manoil@freescale.com>
Date: Fri, 7 Mar 2014 14:52:32 +0200

> Hopefully this explains the problem a bit clearer.

You haven't addressed my concerns at all.

You're disabling an entire body of code with no way to enable
it at all.
