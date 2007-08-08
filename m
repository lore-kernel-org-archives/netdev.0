From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH 2/14] nes: device structures and defines
Date: Wed, 08 Aug 2007 09:39:20 -0700
Message-ID: <adamyx2ou9z.fsf@cisco.com>
References: <200708080045.l780jE9E004667@neteffect.com>
	<200708081555.03588.mb@bu3sch.de> <aday7gmov8o.fsf@cisco.com>
	<200708081830.20129.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, Jeff Garzik <jeff@garzik.org>,
	ggrundstrom@neteffect.com, ewg@lists.openfabrics.org,
	netdev@vger.kernel.org
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:52245 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762743AbXHHQj0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2007 12:39:26 -0400
In-Reply-To: <200708081830.20129.mb@bu3sch.de> (Michael Buesch's message of "Wed, 8 Aug 2007 18:30:19 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > Most likely the __raw_writel variant is portable, but I am not
 > sure. Anybody sure?

Yes, it should be fine.  I use that construct in a few IB drivers.

 - R.
