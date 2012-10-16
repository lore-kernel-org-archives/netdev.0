From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH] net dsa: add new option "master_netdev_autoup"
Date: Tue, 16 Oct 2012 10:03:14 +0200
Message-ID: <20121016080314.GH15785@wantstofly.org>
References: <1350308008-17189-1-git-send-email-giometti@linux.it>
 <1350308008-17189-2-git-send-email-giometti@linux.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Rodolfo Giometti <giometti@linux.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wantstofly.org ([80.101.37.227]:61756 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754632Ab2JPILf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2012 04:11:35 -0400
Content-Disposition: inline
In-Reply-To: <1350308008-17189-2-git-send-email-giometti@linux.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 15, 2012 at 03:33:26PM +0200, Rodolfo Giometti wrote:

> By using this option the user can decide if the master device should
> be turned on when one of the slave devices is opened.
> 
> This functionality is needed if RootFS over NFS is used throught the
> DSA.

NAK

Use an initramfs if you want this.
