From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net-next-2.6] benet: use GFP_KERNEL allocations when
 possible
Date: Tue, 1 Mar 2011 11:46:12 -0600
Message-ID: <20110301174612.GA5927@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:10373 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752592Ab1CARqi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 12:46:38 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Eric.

> -----Original Message-----
> From: Eric Dumazet [mailto:eric.dumazet@gmail.com]
> Sent: Tuesday, March 01, 2011 9:48 AM
> To: Khaparde, Ajit
> Cc: netdev
> Subject: [PATCH net-next-2.6] benet: use GFP_KERNEL allocations when
> possible
> 
> Extend be_alloc_pages() with a gfp parameter, so that we use GFP_KERNEL
> allocations instead of GFP_ATOMIC when not running in softirq context.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Acked-by: Ajit Khaparde <ajit.khaparde@emulex.com>
