From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Drivers: network: more __dev* removal
Date: Sat, 22 Dec 2012 00:03:54 -0800 (PST)
Message-ID: <20121222.000354.1880661972589134958.davem@davemloft.net>
References: <20121221234215.GA13447@kroah.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wfp5p@virginia.edu
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49171 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751181Ab2LVIDz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Dec 2012 03:03:55 -0500
In-Reply-To: <20121221234215.GA13447@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Fri, 21 Dec 2012 15:42:15 -0800

> Remove some __dev* markings that snuck in the 3.8-rc1 merge window in
> the drivers/net/* directory.
> 
> Cc: Bill Pemberton <wfp5p@virginia.edu>
> Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

Applied.
