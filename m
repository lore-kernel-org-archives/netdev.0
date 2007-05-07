From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net/core: Fix error handling
Date: Mon, 07 May 2007 00:33:28 -0700 (PDT)
Message-ID: <20070507.003328.122256749.davem@davemloft.net>
References: <11784936433022-git-send-email-jsipek@cs.sunysb.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jsipek@cs.sunysb.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52371
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754117AbXEGHdY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 May 2007 03:33:24 -0400
In-Reply-To: <11784936433022-git-send-email-jsipek@cs.sunysb.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Josef 'Jeff' Sipek" <jsipek@cs.sunysb.edu>
Date: Sun,  6 May 2007 19:20:43 -0400

> Upon failure to register "ptype" procfs entry, "softnet_stat" was not
> removed, and an incorrect attempt was made to remove the "ptype" entry.
> 
> Signed-off-by: Josef 'Jeff' Sipek <jsipek@cs.sunysb.edu>

Applied, thanks Josef.
