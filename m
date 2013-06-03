From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ibm-ethernet: delete stale MCA and duplicate
 PSERIES dependency
Date: Mon, 03 Jun 2013 00:24:56 -0700 (PDT)
Message-ID: <20130603.002456.1252281827351088397.davem@davemloft.net>
References: <1369836834-9941-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38063 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750925Ab3FCHY5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 03:24:57 -0400
In-Reply-To: <1369836834-9941-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Wed, 29 May 2013 10:13:54 -0400

> MCA support has been removed but this dependency escaped removal.
> Also, there is a duplicate PPC_PSERIES dependency that appeared
> when the ethernet drivers were separated into vendor/model
> specific directories, so we remove that here as well.
> 
> Reported-by: Robert de Rooy <robert.de.rooy@gmail.com>
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

Applied, thanks Paul.
