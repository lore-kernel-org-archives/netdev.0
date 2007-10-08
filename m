From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 2/4][TG3]: ASIC decoding and basic CPMU support.
Date: Mon, 8 Oct 2007 08:18:14 +0100
Message-ID: <20071008071813.GA29669@infradead.org>
References: <1191641858.17453.7.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, andy@greyhouse.net,
	mcarlson@broadcom.com
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:37442 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753266AbXJHHSS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 03:18:18 -0400
Content-Disposition: inline
In-Reply-To: <1191641858.17453.7.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 05, 2007 at 08:37:38PM -0700, Michael Chan wrote:
> [TG3]: ASIC decoding and basic CPMU support.
> 
> Newer products change the way the ASIC revision is obtained.  This patch
> implements how the driver will extract the revision number.

Just curious:  is there a diagram somewhere that shows the relation of
the various tg3 chips to each other and what families exist?
