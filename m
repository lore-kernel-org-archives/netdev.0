From: David Miller <davem@davemloft.net>
Subject: Re: Subject: [PATCH 2/2] atm: br2684: Avoid alignment issues
Date: Tue, 29 Nov 2011 01:21:35 -0500 (EST)
Message-ID: <20111129.012135.1202474841162779100.davem@davemloft.net>
References: <201111281840.pASIehr6011893@cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-atm-general@lists.sourceforge.net
To: chas@cmf.nrl.navy.mil
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34984 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750804Ab1K2GXo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 01:23:44 -0500
In-Reply-To: <201111281840.pASIehr6011893@cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Date: Mon, 28 Nov 2011 13:40:43 -0500

> 
> From: Pascal Hambourg <pascal@plouf.fr.eu.org>
> Date: Wed, 17 Aug 2011 08:37:52 +0200
> Subject: [PATCH 2/2] atm: br2684: Avoid alignment issues
> 
> Use memcmp() instead of cast to u16 when checking the PAD field.
> 
> Signed-off-by: Pascal Hambourg <pascal@plouf.fr.eu.org>
> Signed-off-by: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>

Applied.
