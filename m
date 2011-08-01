From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: Re: [net-next v2 16/71] mlx4: Move the Mellanox driver
Date: Mon, 1 Aug 2011 19:15:41 +0300
Message-ID: <20110801161541.GA8518@mtldesk30>
References: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1312082850-24914-17-git-send-email-jeffrey.t.kirsher@intel.com>
 <CAG4TOxPP-+DnPmveCryXpiiuQT=kvS65yfMDnph2SumuNM+r_A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Roland Dreier <roland@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:57594 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753008Ab1HAQPr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Aug 2011 12:15:47 -0400
Received: by wyg8 with SMTP id 8so1706365wyg.19
        for <netdev@vger.kernel.org>; Mon, 01 Aug 2011 09:15:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAG4TOxPP-+DnPmveCryXpiiuQT=kvS65yfMDnph2SumuNM+r_A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 01, 2011 at 06:10:21AM -0700, Roland Dreier wrote:
> 
> Hi,
> 
> no objection to this, but if we're going to move this code around,
> maybe it makes sense to split the mlx4_core and mlx4_en code
> into separate directories at the same time?
> 

Hi Roland,
it makes sense to split the original mlx4 driver into mlx4_en and
mlx4_core. We will submit patches in a few days.
