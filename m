From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Add eeprom_bad_csum_allow module option to e1000.
Date: Tue, 23 Oct 2007 14:51:04 -0700 (PDT)
Message-ID: <20071023.145104.30179908.davem@davemloft.net>
References: <471E2AD0.1000500@intel.com>
	<471E5C21.8030908@garzik.org>
	<471E6121.9010008@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, ajax@redhat.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: auke-jan.h.kok@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37543
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752304AbXJWVuh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2007 17:50:37 -0400
In-Reply-To: <471E6121.9010008@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Date: Tue, 23 Oct 2007 14:01:21 -0700

> We help everyone out, and if you merge this patch you will prevent
> users from getting to us for support in the first place.

If using the bad eeprom has to be explicitly enabled by the user, your
argument holds no water.  We just need to make sure the patch does
that.
