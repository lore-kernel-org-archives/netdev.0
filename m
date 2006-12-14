From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3][BNX2]: Fix minor loopback problem.
Date: Thu, 14 Dec 2006 15:57:33 -0800 (PST)
Message-ID: <20061214.155733.53337314.davem@davemloft.net>
References: <1166063479.30522.7.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: agospoda@redhat.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56933
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750957AbWLOA2z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Dec 2006 19:28:55 -0500
To: mchan@broadcom.com
In-Reply-To: <1166063479.30522.7.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 13 Dec 2006 18:31:19 -0800

> [BNX2]: Fix minor loopback problem.
> 
> Use the configured MAC address instead of the permanent MAC address
> for loopback frames.
> 
> Update version to 1.5.2.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Also applied, thanks Michael.
