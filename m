From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [1/6] pasemi_mac: fix build break in pasemi_mac_probe()
Date: Wed, 26 Sep 2007 14:22:53 -0700 (PDT)
Message-ID: <20070926.142253.119208342.davem@davemloft.net>
References: <20070926212200.GA24168@lixom.net>
	<20070926212242.GB24168@lixom.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: olof@lixom.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41003
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753187AbXIZVWx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Sep 2007 17:22:53 -0400
In-Reply-To: <20070926212242.GB24168@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Olof Johansson <olof@lixom.net>
Date: Wed, 26 Sep 2007 16:22:43 -0500

> pasemi_mac: fix build break in pasemi_mac_probe()
> 
> Fix breakage caused by recent unification of print_mac() stuff.
> 
> 
> Signed-off-by: Olof Johansson <olof@lixom.net>

This one is in net-2.6.24 already, thanks!
