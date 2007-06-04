From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 0/4] b44 driver improvements
Date: Mon, 4 Jun 2007 17:17:10 -0400
Message-ID: <20070604211710.GJ20299@havoc.gtf.org>
References: <20070604202536.503165465@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gary Zambrano <zambrano@broadcom.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:37547 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752748AbXFDVRL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jun 2007 17:17:11 -0400
Content-Disposition: inline
In-Reply-To: <20070604202536.503165465@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 04, 2007 at 01:25:36PM -0700, Stephen Hemminger wrote:
> While researching why the wired networking was so slow
> on my laptop (not a driver problem); spotted these small
> changes to b44 driver. Nothing urgent, maybe 2.6.23
> or later material.

Seems sane to me.  I'm travelling and will merge this at the beginning
of next week.  I agree netdev#upstream is appropriate, though the
b44_resume() fix may want upstreaming for 2.6.22.

	Jeff



