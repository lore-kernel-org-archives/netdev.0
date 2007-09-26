From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [2/6] pasemi_mac: fix build break in
 pasemi_mac_clean_rx()
Date: Wed, 26 Sep 2007 14:24:26 -0700 (PDT)
Message-ID: <20070926.142426.32740427.davem@davemloft.net>
References: <20070926212200.GA24168@lixom.net>
	<20070926212306.GC24168@lixom.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: olof@lixom.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60796
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757935AbXIZVY0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Sep 2007 17:24:26 -0400
In-Reply-To: <20070926212306.GC24168@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Olof Johansson <olof@lixom.net>
Date: Wed, 26 Sep 2007 16:23:06 -0500

> pasemi_mac: fix build break in pasemi_mac_clean_rx()
> 
> Fix breakage caused by the unification of stats structs.
> 
> 
> Signed-off-by: Olof Johansson <olof@lixom.net>

Jeff, I added this to my net-2.6.24 tree because it fixes
a regression causes by a change in my tree.

I hope you don't mind :-)  You would just push it to me
in the end anyways :))
