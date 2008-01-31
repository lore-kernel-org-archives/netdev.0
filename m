From: Jeff Garzik <jgarzik@redhat.com>
Subject: Re: NET: AX88796 use dev_dbg() instead of printk()
Date: Thu, 31 Jan 2008 09:58:41 -0500
Message-ID: <20080131145840.GG15886@devserv.devel.redhat.com>
References: <20080131112531.187305225@fluff.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Ben Dooks <ben-linux@fluff.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:41099 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751939AbYAaO6p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jan 2008 09:58:45 -0500
Content-Disposition: inline
In-Reply-To: <20080131112531.187305225@fluff.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 31, 2008 at 11:25:31AM +0000, Ben Dooks wrote:
> Change to using dev_dbg() and the other dev_xxx()
> macros instead of printk, and update to use the
> print_mac() helper.
> 
> Signed-off-by: Ben Dooks <ben-linux@fluff.org>

Please send to jgarzik@pobox.com or jeff@garzik.org, the email addresses
I've always used for communication.

The redhat.com address is only for legal sign-offs, not actual
communication.

Thanks,

	Jeff



