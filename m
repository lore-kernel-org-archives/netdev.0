From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] CONFIG_HOTPLUG removal from networking core
Date: Sat, 22 Dec 2012 00:03:46 -0800 (PST)
Message-ID: <20121222.000346.2002034049441007814.davem@davemloft.net>
References: <20121221234429.GB13447@kroah.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wfp5p@virginia.edu
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49165 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750799Ab2LVIDr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Dec 2012 03:03:47 -0500
In-Reply-To: <20121221234429.GB13447@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Fri, 21 Dec 2012 15:44:29 -0800

> CONFIG_HOTPLUG is always enabled now, so remove the unused code that was
> trying to be compiled out when this option was disabled, in the
> networking core.
> 
> Cc: Bill Pemberton <wfp5p@virginia.edu>
> Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

Applied.
