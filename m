From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 15/61] net: struct device - replace bus_id with
 dev_name(), dev_set_name()
Date: Tue, 24 Mar 2009 23:29:31 -0700 (PDT)
Message-ID: <20090324.232931.65484505.davem@davemloft.net>
References: <20090325001659.GA22461@kroah.com>
	<1237940825-22904-15-git-send-email-gregkh@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kay.sievers@vrfy.org,
	netdev@vger.kernel.org
To: gregkh@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40105
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754600AbZCYG3n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 02:29:43 -0400
In-Reply-To: <1237940825-22904-15-git-send-email-gregkh@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Kroah-Hartman <gregkh@suse.de>
Date: Tue, 24 Mar 2009 17:26:19 -0700

> From: Kay Sievers <kay.sievers@vrfy.org>
> 
> Cc: davem@davemloft.net
> Cc: netdev@vger.kernel.org
> Acked-by: Greg Kroah-Hartman <gregkh@suse.de>
> Signed-off-by: Kay Sievers <kay.sievers@vrfy.org>

None of this patch applies to net-next-2.6

Probably because, just like the wimax case, these changes
are already there.
