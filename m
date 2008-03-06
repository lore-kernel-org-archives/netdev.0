From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: replace remaining __FUNCTION__ occurances
Date: Wed, 05 Mar 2008 18:58:15 -0800 (PST)
Message-ID: <20080305.185815.179794444.davem@davemloft.net>
References: <1204575406.3266.55.camel@brick>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: harvey.harrison@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54174
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1765856AbYCFC6Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2008 21:58:16 -0500
In-Reply-To: <1204575406.3266.55.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harvey Harrison <harvey.harrison@gmail.com>
Date: Mon, 03 Mar 2008 12:16:46 -0800

> __FUNCTION__ is gcc-specific, use __func__
> 
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>

This doesn't apply cleanly to net-2.6.26 and I don't
think it's appropriate for 2.6.25 so you'll need to
respin this patch.
