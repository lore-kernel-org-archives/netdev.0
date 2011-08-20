From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] dm9000: define debug level as a module parameter
Date: Sat, 20 Aug 2011 14:17:30 -0700 (PDT)
Message-ID: <20110820.141730.1510914565000290219.davem@davemloft.net>
References: <1313785900-27367-1-git-send-email-vz@mleia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ben-linux@fluff.org
To: vz@mleia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42469 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752726Ab1HTVR5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Aug 2011 17:17:57 -0400
In-Reply-To: <1313785900-27367-1-git-send-email-vz@mleia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladimir Zapolskiy <vz@mleia.com>
Date: Fri, 19 Aug 2011 23:31:40 +0300

> This change allows to get driver specific debug messages output
> providing a module parameter. As far as the maximum level of verbosity
> is too high, it is demoted by default.
> 
> Signed-off-by: Vladimir Zapolskiy <vz@mleia.com>

Applied to net-next, thanks.
