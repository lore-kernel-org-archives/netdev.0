From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH, RTF/RFC] bcm43xx: Enable local IRQs while executing periodic work
Date: Mon, 5 Jun 2006 14:54:38 -0400
Message-ID: <20060605185433.GF6068@tuxdriver.com>
References: <200605231723.10028.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([24.172.12.4]:21513 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1751288AbWFESys (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2006 14:54:48 -0400
To: Michael Buesch <mb@bu3sch.de>
Content-Disposition: inline
In-Reply-To: <200605231723.10028.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 23, 2006 at 05:23:09PM +0200, Michael Buesch wrote:

> I would like to get this into wireless-2.6, but before that
> happens I would like to have a few regression tests by people.
> Please apply this and run high network traffic for 10-15 minutes.
> Please enable kernel spinlock lockup and recursion detection
> while testing.

It has almost been two weeks...do we want this patch, or not?

John
-- 
John W. Linville
linville@tuxdriver.com
