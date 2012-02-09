From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2 net-next] cnic: set error flag when iSCSI
 connection fails
Date: Thu, 09 Feb 2012 14:04:06 -0500 (EST)
Message-ID: <20120209.140406.710067584998451284.davem@davemloft.net>
References: <1328758437-18306-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57394 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757901Ab2BITEK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2012 14:04:10 -0500
In-Reply-To: <1328758437-18306-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 8 Feb 2012 19:33:56 -0800

> From: Jeffrey Huang <huangjw@broadcom.com>
> 
> to speed up error recovery due to SPQ failures.  The error flag will
> expedite the recovery process by skipping the timeouts.
> 
> Signed-off-by: Jeffrey Huang <huangjw@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
