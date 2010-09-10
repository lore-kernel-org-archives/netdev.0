From: Dan Carpenter <error27@gmail.com>
Subject: Re: [patch] vxge: potential NULL dereference
Date: Fri, 10 Sep 2010 23:12:57 +0200
Message-ID: <20100910211257.GI5959@bicker>
References: <20100910115423.GC5959@bicker> <20100910.133255.137830993.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ramkrishna.vepa@exar.com, sivakumar.subramani@exar.com,
	sreenivasa.honnur@exar.com, jon.mason@exar.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:53998 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754773Ab0IJVNn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Sep 2010 17:13:43 -0400
Content-Disposition: inline
In-Reply-To: <20100910.133255.137830993.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 10, 2010 at 01:32:55PM -0700, David Miller wrote:
> So we can simply remove the first NULL check as this can never actually
> be NULL.

Ok.  Thanks, Dave.  I should have looked more into this myself.  I'll
send a patch to remove the check tomorrow.

regards,
dan carpenter

