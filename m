From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] be2net: add dma_mapping_error() check for
 dma_map_page()
Date: Wed, 15 Jan 2014 16:50:54 -0800 (PST)
Message-ID: <20140115.165054.191529105886547517.davem@davemloft.net>
References: <1389780694-6299-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sathya.perla@emulex.com,
	subbu.seetharaman@emulex.com, ajit.khaparde@emulex.com
To: ivecera@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43079 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752308AbaAPAuz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 19:50:55 -0500
In-Reply-To: <1389780694-6299-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ivan Vecera <ivecera@redhat.com>
Date: Wed, 15 Jan 2014 11:11:34 +0100

> The driver does not check value returned by dma_map_page. The patch
> fixes this.
> 
> v2: Removed the bugfix for non-bug ;-) (thanks Sathya)
> 
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>

Applied, thank you.
