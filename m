From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/Space: delete orphaned externs from
 deleted drivers
Date: Mon, 03 Jan 2011 11:06:47 -0800 (PST)
Message-ID: <20110103.110647.59672573.davem@davemloft.net>
References: <1293923701-14147-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55714
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751285Ab1ACTGQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jan 2011 14:06:16 -0500
In-Reply-To: <1293923701-14147-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Sat,  1 Jan 2011 18:15:01 -0500

> The drivers associated with the prototypes in this commit have
> been deleted some time ago, but the externs escaped detection.
> Using a simple "git grep" shows that these references are
> historical artefacts, only mentioned by the deleted lines.
> 
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

Applied.
