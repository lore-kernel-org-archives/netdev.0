From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/20] Delete more semi-useless stuff from
 TIPC.
Date: Sat, 01 Jan 2011 14:56:31 -0800 (PST)
Message-ID: <20110101.145631.189697465.davem@davemloft.net>
References: <1293857975-30267-1-git-send-email-paul.gortmaker@windriver.com>
	<20110101.135952.226766850.davem@davemloft.net>
	<20110101225330.GF30150@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37325
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750973Ab1AAW4A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Jan 2011 17:56:00 -0500
In-Reply-To: <20110101225330.GF30150@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Sat, 1 Jan 2011 17:53:31 -0500

> Subject: [PATCH] tipc: update log.h re-include protection to reflect new name
> 
> The tipc/dbg.h file was recently renamed to tipc/log.h,
> but the re-include define was not updated accordingly.
> 
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

Applied, thanks Paul.
