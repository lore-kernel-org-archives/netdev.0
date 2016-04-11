From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/11] FUJITSU Extended Socket driver version
 1.1
Date: Mon, 11 Apr 2016 11:56:17 -0400 (EDT)
Message-ID: <20160411.115617.2124648532876219571.davem@davemloft.net>
References: <1460362136-14968-1-git-send-email-izumi.taku@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: izumi.taku@jp.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34115 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932307AbcDKP4W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 11:56:22 -0400
In-Reply-To: <1460362136-14968-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This submission is of an extremely low quality.

All of your ioctl additions are completely inappropriate, as are your
debugfs facilities.  You must remove all of them completely.
