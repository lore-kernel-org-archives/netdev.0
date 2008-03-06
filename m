From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: replace remaining __FUNCTION__ occurrences
Date: Wed, 05 Mar 2008 20:47:57 -0800 (PST)
Message-ID: <20080305.204757.13821992.davem@davemloft.net>
References: <1204575406.3266.55.camel@brick>
	<20080305.185815.179794444.davem@davemloft.net>
	<1204773069.14154.58.camel@brick>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: harvey.harrison@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38753
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754178AbYCFEsD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2008 23:48:03 -0500
In-Reply-To: <1204773069.14154.58.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harvey Harrison <harvey.harrison@gmail.com>
Date: Wed, 05 Mar 2008 19:11:09 -0800

> __FUNCTION__ is gcc-specific, use __func__
> 
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>

Applied, thanks Harvey.
