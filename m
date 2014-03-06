From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] bonding: options handling cleanup
Date: Thu, 06 Mar 2014 16:09:20 -0500 (EST)
Message-ID: <20140306.160920.1863058086379750751.davem@davemloft.net>
References: <20140304163425.44995c59@nehalam.linuxnetplumber.net>
	<20140304163644.432f60d0@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, andy@greyhouse.net, vfalico@redhat.com,
	nikolay@redhat.com, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33382 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753247AbaCFVJW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 16:09:22 -0500
In-Reply-To: <20140304163644.432f60d0@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Tue, 4 Mar 2014 16:36:44 -0800

> Make local functions static (ie. only used in bond_options.c)
> Make bond options parsing tables constant.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied.
