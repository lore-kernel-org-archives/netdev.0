From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netpoll: fix race on poll_list resulting in garbage
 entry
Date: Wed, 17 Dec 2008 19:29:36 -0800 (PST)
Message-ID: <20081217.192936.169928910.davem@davemloft.net>
References: <20081217211628.GD7356@hmsreliant.think-freely.org>
	<20081217133131.44a4f67f@extreme>
	<20081218011306.GA32191@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, jarkao2@gmail.com, netdev@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34700
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751337AbYLRD3e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 22:29:34 -0500
In-Reply-To: <20081218011306.GA32191@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Wed, 17 Dec 2008 20:13:06 -0500

> Ok, here you go, one omnibus patch

This doesn't apply to net-next-2.6, not even by a country mile.
:-)

Please respin this, thanks.
