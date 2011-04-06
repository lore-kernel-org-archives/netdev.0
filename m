From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 12/12] qlcnic: convert to set_phys_id
Date: Wed, 06 Apr 2011 14:32:26 -0700 (PDT)
Message-ID: <20110406.143226.42783062.davem@davemloft.net>
References: <20110404184340.604594357@linuxplumber.net>
	<20110404184502.382340801@linuxplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, amit.salecha@qlogic.com,
	anirban.chakraborty@qlogic.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53227
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932295Ab1DFVdC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2011 17:33:02 -0400
In-Reply-To: <20110404184502.382340801@linuxplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 04 Apr 2011 11:43:52 -0700

> Convert driver to use new ethtool set_phys_id.
> Not completely sure that this is correct for all cases of device
> up/down and doing operation. Compile tested only.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Please address the feedback given by qlcnic developers.

Thanks.
