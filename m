From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] ethtool: device independent rx_csum and
 get_flags routines
Date: Sun, 26 Jul 2009 19:49:57 -0700 (PDT)
Message-ID: <20090726.194957.162341485.davem@davemloft.net>
References: <1248305902.1061.84.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sri@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56709
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755480AbZG0Ctu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jul 2009 22:49:50 -0400
In-Reply-To: <1248305902.1061.84.camel@w-sridhar.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Wed, 22 Jul 2009 16:38:22 -0700

> [PATCH net-next-2.6] ethtool: add device independent rx_csum and get_flags routines
> 
> This helps avoid error messages with ethtool -k on devices that
> don't provide device specific routines.
> 
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

Applied.
