From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][ICMP]: Dst entry leak in icmp_send host re-lookup code.
Date: Wed, 26 Mar 2008 02:06:57 -0700 (PDT)
Message-ID: <20080326.020657.239695358.davem@davemloft.net>
References: <47E91CD0.8000901@openvz.org>
	<20080326033200.GA31748@gondor.apana.org.au>
	<47EA112A.2070406@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, den@openvz.org,
	netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55340
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750953AbYCZJG6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2008 05:06:58 -0400
In-Reply-To: <47EA112A.2070406@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Wed, 26 Mar 2008 12:02:34 +0300

> David, plz, disregard this patch, I'll send a new one in a moment.

Ok, but please fix the net-2.6.26 build regression I just reported
first.
