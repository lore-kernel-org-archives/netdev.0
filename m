From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH NEXT 1/3] netxen: fix vlan tso case
Date: Wed, 05 Aug 2009 12:41:10 -0700 (PDT)
Message-ID: <20090805.124110.124961658.davem@davemloft.net>
References: <1249493649-26336-1-git-send-email-dhananjay@netxen.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.com, netdev@vger.kernel.org
To: dhananjay@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39661
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751893AbZHETlB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2009 15:41:01 -0400
In-Reply-To: <1249493649-26336-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dhananjay Phadke <dhananjay@netxen.com>
Date: Wed,  5 Aug 2009 10:34:07 -0700

> Fix the calculation of remaining header length in TSO
> over vlan device case. This was inadvertently missed
> out in patch 028afe719855a157e32450c ("netxen: add vlan
> tx acceleration support").
> 
> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>

Applied.
