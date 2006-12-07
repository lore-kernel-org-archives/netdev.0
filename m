From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/7][TG3]: Fix Phy loopback.
Date: Thu, 07 Dec 2006 00:20:03 -0800 (PST)
Message-ID: <20061207.002003.93399884.davem@davemloft.net>
References: <1165477566.8488.27.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60874
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1031831AbWLGITv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Dec 2006 03:19:51 -0500
To: mchan@broadcom.com
In-Reply-To: <1165477566.8488.27.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 06 Dec 2006 23:46:06 -0800

> [TG3]: Fix Phy loopback.
> 
> Phy loopback on most 10/100 devices need to be run in 1Gbps mode in
> GMII mode.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, thanks Michael.
