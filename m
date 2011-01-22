From: Flavio Leitner <fleitner@redhat.com>
Subject: Re: [PATCH 1/4] e1000e: convert to stats64
Date: Sat, 22 Jan 2011 11:42:23 -0200
Message-ID: <20110122134223.GH3095@redhat.com>
References: <1295697376-2984-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1295697376-2984-2-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47356 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752476Ab1AVNma (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Jan 2011 08:42:30 -0500
Content-Disposition: inline
In-Reply-To: <1295697376-2984-2-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 22, 2011 at 03:56:13AM -0800, Jeff Kirsher wrote:
> Based on the patch provided by Flavio Leitner <fleitner@redhat.com>
> Provides accurate stats at the time user reads them.
> 
> v2: fixed whitespace/merging issues (by Jeff Kirsher)
> v3: fixed namespacing issues (by Bruce Allan)
> 
> CC: Flavio Leitner <fleitner@redhat.com>
> CC: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
> ---
>  drivers/net/e1000e/e1000.h   |    5 ++-
>  drivers/net/e1000e/ethtool.c |   37 +++++++++++----------
>  drivers/net/e1000e/netdev.c  |   72 +++++++++++++++++++++++++++++++++---------
>  3 files changed, 80 insertions(+), 34 deletions(-)
 
Signed-off-by: Flavio Leitner <fleitner@redhat.com>

thanks,
Flavio
