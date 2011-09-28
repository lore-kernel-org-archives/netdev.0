From: David Miller <davem@davemloft.net>
Subject: Re: [patch] usbnet: add timestamping support
Date: Wed, 28 Sep 2011 03:20:57 -0400 (EDT)
Message-ID: <20110928.032057.938343201578831873.davem@davemloft.net>
References: <20110921121151.Horde.2_LlPML8999Oebhn0-QlTpA@webmail.df.eu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oneukum@suse.de
To: michael@riesch.at
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53256 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751343Ab1I1HVJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2011 03:21:09 -0400
In-Reply-To: <20110921121151.Horde.2_LlPML8999Oebhn0-QlTpA@webmail.df.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Riesch <michael@riesch.at>
Date: Wed, 21 Sep 2011 12:11:51 +0200

> @@ -238,6 +238,10 @@ void usbnet_skb_return (struct usbnet *dev,
> struct sk_buff *skb)

Patch is severly corrupted by your email client.

Correct this (see Documentation/email-clients.txt), send a test patch
to yourself, and only resubmit this change when you can successfully
apply a patch you send to youself.
