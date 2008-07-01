From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [Linux-ATM-General] [PATCH] firmware: convert Ambassador ATM
	driver to request_firmware()
Date: Tue, 01 Jul 2008 14:06:13 +0100
Message-ID: <1214917573.10393.391.camel@pmac.infradead.org>
References: <200807011255.m61CtW6x003038@cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-atm-general@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:40420 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754566AbYGANGQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2008 09:06:16 -0400
In-Reply-To: <200807011255.m61CtW6x003038@cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-07-01 at 08:55 -0400, Chas Williams (CONTRACTOR) wrote:
> In message <1214853492.10393.350.camel@pmac.infradead.org>,David Woodhouse writes:
> >True. But if you were to put the driver into an initrd, for example,
> 
> that is a pretty small number of people.  small enough that a physicist
> would call it zero. regardless:

Perhaps so. But in that case why do we bother with MODULE_FIRMWARE at
all? :)

-- 
dwmw2

