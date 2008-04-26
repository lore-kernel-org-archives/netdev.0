From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][CAN]: Fix copy_from_user() results interpretation.
Date: Sat, 26 Apr 2008 02:10:01 -0700 (PDT)
Message-ID: <20080426.021001.18044508.davem@davemloft.net>
References: <4812C973.5000504@grandegger.com>
	<20080426064007.GA20558@uranus.ravnborg.org>
	<4812E73A.6060104@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sam@ravnborg.org, wg@grandegger.com, urs.thuermann@volkswagen.de,
	netdev@vger.kernel.org, socketcan-core@lists.berlios.de,
	oliver.hartkopp@volkswagen.de, xemul@openvz.org
To: oliver@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39495
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752083AbYDZJKB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Apr 2008 05:10:01 -0400
In-Reply-To: <4812E73A.6060104@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <oliver@hartkopp.net>
Date: Sat, 26 Apr 2008 10:26:34 +0200

> Btw. the cleanup an removal of the err variable usage in the pointed 
> cases is a good suggestion. So even when the two latest changes in Sam's 
> patch are not that obvious to be able to be reviewed locally i would 
> like to ack this patch.

Right, I also have no problem with Sam's patch at all and plan to
apply it.

Thanks.
