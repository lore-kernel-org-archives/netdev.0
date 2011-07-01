From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: rds: fix const array syntax
Date: Fri, 01 Jul 2011 16:16:27 -0700 (PDT)
Message-ID: <20110701.161627.480935317086519859.davem@davemloft.net>
References: <1309560635-17514-1-git-send-email-Gregory.Dietsche@cuw.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andy.grover@oracle.com, netdev@vger.kernel.org,
	rds-devel@oss.oracle.com, kernel-janitors@vger.kernel.org
To: Gregory.Dietsche@cuw.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52745 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757689Ab1GAXQc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2011 19:16:32 -0400
In-Reply-To: <1309560635-17514-1-git-send-email-Gregory.Dietsche@cuw.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Dietsche <Gregory.Dietsche@cuw.edu>
Date: Fri,  1 Jul 2011 17:50:35 -0500

> Correct the syntax so that both array and pointer are const.
> 
> Signed-off-by: Greg Dietsche <Gregory.Dietsche@cuw.edu>

Applied.
