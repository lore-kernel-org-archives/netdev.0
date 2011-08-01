From: Roland Dreier <roland@kernel.org>
Subject: Re: [net-next v2 16/71] mlx4: Move the Mellanox driver
Date: Mon, 1 Aug 2011 06:10:21 -0700
Message-ID: <CAG4TOxPP-+DnPmveCryXpiiuQT=kvS65yfMDnph2SumuNM+r_A@mail.gmail.com>
References: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com> <1312082850-24914-17-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:42419 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751565Ab1HANKl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Aug 2011 09:10:41 -0400
Received: by iyb12 with SMTP id 12so6878658iyb.19
        for <netdev@vger.kernel.org>; Mon, 01 Aug 2011 06:10:41 -0700 (PDT)
In-Reply-To: <1312082850-24914-17-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 30, 2011 at 8:26 PM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> Moves the Mellanox driver into drivers/net/ethernet/mellanox/ and
> make the necessary Kconfig and Makefile changes.

Hi,

no objection to this, but if we're going to move this code around,
maybe it makes sense to split the mlx4_core and mlx4_en code
into separate directories at the same time?

 - R.
