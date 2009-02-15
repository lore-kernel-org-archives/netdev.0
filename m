From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: replace __constant_{endian} uses in net headers
Date: Sat, 14 Feb 2009 22:58:44 -0800 (PST)
Message-ID: <20090214.225844.153303138.davem@davemloft.net>
References: <1234401327.5566.18.camel@brick>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: harvey.harrison@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58850
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751241AbZBOG6t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Feb 2009 01:58:49 -0500
In-Reply-To: <1234401327.5566.18.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harvey Harrison <harvey.harrison@gmail.com>
Date: Wed, 11 Feb 2009 17:15:27 -0800

> Base versions handle constant folding now.  For headers exposed to
> userspace, we must only expose the __ prefixed versions.
> 
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>

Applied, thanks.
