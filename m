From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [NET] Nuke SET_NETDEV_DEVICE macro
Date: Wed, 12 Sep 2007 17:39:22 +0100
Message-ID: <20070912163922.GA9615@linux-mips.org>
References: <20070912162713.GA15519@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jeff@garzik.org>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:54015 "EHLO
	ftp.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751153AbXILQjY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 12:39:24 -0400
Received: from localhost.localdomain ([127.0.0.1]:40663 "EHLO
	dl5rb.ham-radio-op.net") by ftp.linux-mips.org with ESMTP
	id S20023543AbXILQjW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Sep 2007 17:39:22 +0100
Content-Disposition: inline
In-Reply-To: <20070912162713.GA15519@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 12, 2007 at 05:27:13PM +0100, Ralf Baechle wrote:

> It's been a useless no-op for long enough in 2.6 so I figured it's time to
> remove it.  The number of people that could object because they're
> maintaining unified 2.4 and 2.6 drivers is probably rather small.

Whops, wrong patch and subject, please ignore.
