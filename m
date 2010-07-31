From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/4] be2net: fix to correctly know if driver
 needs to run for a VF or a PF
Date: Fri, 30 Jul 2010 23:59:25 -0700 (PDT)
Message-ID: <20100730.235925.70200801.davem@davemloft.net>
References: <20100729161522.GA15448@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ajitk@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50739
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752873Ab0GaG7I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jul 2010 02:59:08 -0400
In-Reply-To: <20100729161522.GA15448@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajitk@serverengines.com>
Date: Thu, 29 Jul 2010 21:45:32 +0530

> Move be_check_sriov_fn_type to appropriate place to correctly determine
> if the be2net driver needs to work as a VF driver or a PF driver.
> 
> Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>

Applied.
