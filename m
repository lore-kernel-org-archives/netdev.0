From: David Miller <davem@davemloft.net>
Subject: Re: [patch 06/10] 802.3ad: generalize out mac address initializer
Date: Fri, 26 Dec 2008 13:40:54 -0800 (PST)
Message-ID: <20081226.134054.114616891.davem@davemloft.net>
References: <20081223220101.747816175@jonathan.eitzenberger.org>
	<20081223220557.631160792@jonathan.eitzenberger.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, netdev@vger.kernel.org
To: holger@eitzenberger.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55952
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752743AbYLZVkw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Dec 2008 16:40:52 -0500
In-Reply-To: <20081223220557.631160792@jonathan.eitzenberger.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Holger Eitzenberger <holger@eitzenberger.org>
Date: Tue, 23 Dec 2008 23:01:07 +0100

> Generalize out mac address initializer for the LACPDU multicast
> address and use in two places.  Remove the now unused
> AD_MULTICAST_LACPDU_ADDR.
> 
> Signed-off-by: Holger Eitzenberger <holger@eitzenberger.org>

Applied.
