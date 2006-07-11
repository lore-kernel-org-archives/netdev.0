From: Daniel Drake <dsd@gentoo.org>
Subject: Re: [patch] do not allow IPW_2100=Y or IPW_2200=Y
Date: Tue, 11 Jul 2006 21:59:48 +0100
Message-ID: <44B41144.5030709@gentoo.org>
References: <20060710152032.GA8540@elf.ucw.cz> <200607102305.06572.mb@bu3sch.de> <44B3912F.3010300@gentoo.org> <200607112239.17405.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, Pavel Machek <pavel@ucw.cz>,
	yi.zhu@intel.com, jketreno@linux.intel.com,
	Netdev list <netdev@vger.kernel.org>, linville@tuxdriver.com,
	kernel list <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta07-winn.ispmail.ntl.com ([81.103.221.47]:41169 "EHLO
	mtaout01-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S1751157AbWGKUyI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jul 2006 16:54:08 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200607112239.17405.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Buesch wrote:
> Yes. We have a PROM that is readable without firmware.
> (And we actually do this and did it forever. So I don't know
> where your assumption comes from ;) )

It wasn't an assumption: I was stating something about the Intel cards. 
It is not possible to determine the MAC address for ipw2100/ipw2200 
until the firmware is loaded.

Daniel
