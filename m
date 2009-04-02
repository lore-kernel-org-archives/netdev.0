From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fsl_pq_mdio: Fix compile failure
Date: Thu, 02 Apr 2009 13:57:42 -0700 (PDT)
Message-ID: <20090402.135742.99633675.davem@davemloft.net>
References: <1238679923-4370-1-git-send-email-galak@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	segher@kernel.crashing.org
To: galak@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42153
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755666AbZDBU5x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2009 16:57:53 -0400
In-Reply-To: <1238679923-4370-1-git-send-email-galak@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kumar Gala <galak@kernel.crashing.org>
Date: Thu,  2 Apr 2009 08:45:23 -0500

> From: Segher Boessenkool <segher@kernel.crashing.org>
> 
> Add EXPORT_SYMBOL_GPL(fsl_pq_mdio_bus_name) for module builds
> 
> Signed-off-by: Segher Boessenkool <segher@kernel.crashing.org>
> Signed-off-by: Kumar Gala <galak@kernel.crashing.org>

Applied, thanks.
