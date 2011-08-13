From: Chris Metcalf <cmetcalf@tilera.com>
Subject: Re: [net-next 10/12] tile: Move the Tilera driver
Date: Sat, 13 Aug 2011 08:15:12 -0400
Message-ID: <4E466AD0.4030704@tilera.com>
References: <1313222196-10074-1-git-send-email-jeffrey.t.kirsher@intel.com> <1313222196-10074-11-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<gospo@redhat.com>, <sassmann@redhat.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usmamail.tilera.com ([206.83.70.75]:40899 "EHLO
	USMAMAIL.TILERA.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752688Ab1HNBN6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Aug 2011 21:13:58 -0400
In-Reply-To: <1313222196-10074-11-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/13/2011 3:56 AM, Jeff Kirsher wrote:
> Move the Tilera driver into drivers/net/ethernet/tile and
> make the necessary Kconfig and Makefile changes.
>
> Updated the Kconfig so that the options defualt to y if TILE kernel.
>
> CC: Chris Metcalf <cmetcalf@tilera.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Acked-by: Chris Metcalf <cmetcalf@tilera.com>

But note commit typo, "defualt" not "default" :-)

-- 
Chris Metcalf, Tilera Corp.
http://www.tilera.com

