From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] be2net:Patch to perform function reset at
 initialization
Date: Wed, 05 Aug 2009 13:05:35 -0700 (PDT)
Message-ID: <20090805.130535.239816373.davem@davemloft.net>
References: <20090805113923.GA15874@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sarveshwarb@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45389
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752346AbZHEUF0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2009 16:05:26 -0400
In-Reply-To: <20090805113923.GA15874@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Date: Wed, 5 Aug 2009 17:09:32 +0530

> This patch is a bug fix to avoid system going into a bad state when driver
> is loaded in context of kdump kernel. The patch fixes the issue by performing
> a soft reset of pci function at probe time.
> 
> Signed-off-by: sarveshwarb <sarveshwarb@serverengines.com>

Applied, thanks.
