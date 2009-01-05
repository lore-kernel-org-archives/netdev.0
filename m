From: David Miller <davem@davemloft.net>
Subject: Re: [NET-2.6 PATCH] e100: cosmetic cleanup
Date: Sun, 04 Jan 2009 17:13:45 -0800 (PST)
Message-ID: <20090104.171345.257011394.davem@davemloft.net>
References: <20081231233057.23132.43080.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41320
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751029AbZAEBNl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Jan 2009 20:13:41 -0500
In-Reply-To: <20081231233057.23132.43080.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 31 Dec 2008 15:31:50 -0800

> Add missing space after if, switch, for and while keywords.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

I find it kind of rotten that you held up the e100 firmware
submission so you could do "important testing" and then
you fire off a completely useless patch like this meanwhile.

Applied, but know that this kind of prioritization really
and truly ticks me off.
