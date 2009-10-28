From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 4/7] fsl_pq_mdio: Add Suport for etsec2.0 devices.
Date: Wed, 28 Oct 2009 02:43:25 -0700 (PDT)
Message-ID: <20091028.024325.134189895.davem@davemloft.net>
References: <12566625182528-git-send-email-sandeep.kumar@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sandeep.kumar@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34787
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751759AbZJ1JnB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 05:43:01 -0400
In-Reply-To: <12566625182528-git-send-email-sandeep.kumar@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sandeep Gopalpet <sandeep.kumar@freescale.com>
Date: Tue, 27 Oct 2009 22:25:18 +0530

> This patch adds mdio support for etsec2.0 devices.
> 
> Modified the fsl_pq_mdio structure to include the new mdio
> members.
> 
> Signed-off-by: Sandeep Gopalpet <sandeep.kumar@freescale.com>

This is the third time you've submitted this patch, and for
the third time it DOES NOT apply to net-next-2.6 at all when
I try to apply this gianfar patch series.

You must be patching against another tree that has some changes
that conflict with this one.

Sort this out before submitting this again.

If you submit once more this same series, and it doesn't apply
properly to net-next-2.6, I will flat our ignore your submissions
for a week or so.

You are wasting that much of my time by doing this over and over.

Get your act together.
