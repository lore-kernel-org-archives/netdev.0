From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bonding: Avoid possible de-sync with arp_validate
Date: Fri, 06 Sep 2013 13:58:36 -0400 (EDT)
Message-ID: <20130906.135836.365469022075105934.davem@davemloft.net>
References: <994d2dc994a801fc3aae7aa912266b09ea45d95c.1378489255.git.mleitner@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, naleksan@redhat.com, fubar@us.ibm.com,
	andy@greyhouse.net
To: mleitner@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60032 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751086Ab3IFR6l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Sep 2013 13:58:41 -0400
In-Reply-To: <994d2dc994a801fc3aae7aa912266b09ea45d95c.1378489255.git.mleitner@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Date: Fri,  6 Sep 2013 14:41:53 -0300

> Please queue this one for -stable trees too.

This is very much not the correct way to submit a patch.

First of all, you haven't signed off on the patch.

Second of all, any supplemental information that doesn't belong in the
commit message needs to go after a "---" dileanator line.
