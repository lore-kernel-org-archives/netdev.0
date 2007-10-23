From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Add eeprom_bad_csum_allow module option to e1000.
Date: Tue, 23 Oct 2007 14:48:57 -0700 (PDT)
Message-ID: <20071023.144857.03983847.davem@davemloft.net>
References: <1193156487.26974.39.camel@localhost.localdomain>
	<471E2AD0.1000500@intel.com>
	<471E5C21.8030908@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, ajax@redhat.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37538
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751564AbXJWVsa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2007 17:48:30 -0400
In-Reply-To: <471E5C21.8030908@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jeff@garzik.org>
Date: Tue, 23 Oct 2007 16:40:01 -0400

> Sorry, I disagree.  Just as with e100, if there is a clear way the user 
> can recover their setup -- and Adam says his was effective -- I don't 
> see why we should be denying users the ability to use their own hardware.

I'd like to second these sentiments.

Just because you can come up with cases where using a wrong
eeprom would fail, does not mean the facility should not be
provided at all.
