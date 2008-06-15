From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [PATCH] firmware: convert e100 driver to request_firmware()
Date: Sun, 15 Jun 2008 18:51:59 +0100
Message-ID: <1213552319.26255.498.camel@pmac.infradead.org>
References: <1213522966.26255.433.camel@pmac.infradead.org>
	 <48555677.7040209@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	Auke Kok <auke-jan.h.kok@intel.com>,
	Jaswinder Singh <jaswinderlinux@gmail.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:33832 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758614AbYFORwE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jun 2008 13:52:04 -0400
In-Reply-To: <48555677.7040209@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2008-06-15 at 13:50 -0400, Jeff Garzik wrote:
> NAK - firmware should not be stored in a separate directory from the 
> driver to which it is intimately tied.

Your objection is noted, but ignored.

-- 
dwmw2

