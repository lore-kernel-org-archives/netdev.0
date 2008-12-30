From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 0/5] qlge: Fixes from PPC bringup.
Date: Tue, 30 Dec 2008 13:11:22 -0800
Message-ID: <20081230211122.GD16018@susedev.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bhutchings@solarflare.com, hch@infradead.org,
	"ron.mercer@qlogic.com"@linux-7mw0.qlogic.com,
	"netdev@vger.kernel.org"@linux-7mw0.qlogic.com
To: davem@davemloft.net, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:38364 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751566AbYL3VLW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Dec 2008 16:11:22 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave/Jeff,

The attached patch series replaces those I sent on 12/24.  Patch 3/5 is
cleaned up per Ben and Christoph.  The rest have the file mode changed
removed per Dave.

Christoph also asked me to verify the entire driver for endianess with
sparse which I am now working on.  In the meantime I would like to get
these changes dropped in if possible.

Regards,
Ron

