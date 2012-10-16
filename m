From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH] net dsa: add per port phy address mapping
Date: Tue, 16 Oct 2012 10:02:39 +0200
Message-ID: <20121016080239.GG15785@wantstofly.org>
References: <1350308008-17189-1-git-send-email-giometti@linux.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Rodolfo Giometti <giometti@linux.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wantstofly.org ([80.101.37.227]:61757 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754819Ab2JPILg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2012 04:11:36 -0400
Content-Disposition: inline
In-Reply-To: <1350308008-17189-1-git-send-email-giometti@linux.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 15, 2012 at 03:33:25PM +0200, Rodolfo Giometti wrote:

> In some circumstances ports' phy addresses must be remapped in a custom
> manner (i.e. when phys have multiple MDIO addresses).

Can you give an example of when this is needed (i.e. on which
switch chips)?
