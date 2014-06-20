From: David Miller <davem@davemloft.net>
Subject: Re: net: return actual error on register_queue_kobjects
Date: Thu, 19 Jun 2014 18:12:45 -0700 (PDT)
Message-ID: <20140619.181245.559896665354031961.davem@davemloft.net>
References: <20140619212840.GA15522@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff.liu@oracle.com, netdev@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45415 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753688AbaFTBMx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2014 21:12:53 -0400
In-Reply-To: <20140619212840.GA15522@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 20 Jun 2014 00:28:40 +0300

> The patch d36a4f4b4723: "net: return actual error on
> register_queue_kobjects" from Jun 17, 2014, leads to the following
> static checker warning:

I've reverted it from my tree, thanks.
