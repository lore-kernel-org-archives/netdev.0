From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] bonding 802.3ad: Rename rx_machine_lock to
 state_machine_lock
Date: Mon, 07 Mar 2011 16:03:21 -0800 (PST)
Message-ID: <20110307.160321.58423319.davem@davemloft.net>
References: <1299226152-23578-1-git-send-email-nils.carlson@ericsson.com>
	<1299226152-23578-2-git-send-email-nils.carlson@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, andy@greyhouse.net, netdev@vger.kernel.org
To: nils.carlson@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35133
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756769Ab1CHACn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2011 19:02:43 -0500
In-Reply-To: <1299226152-23578-2-git-send-email-nils.carlson@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nils Carlson <nils.carlson@ericsson.com>
Date: Fri, 4 Mar 2011 09:09:12 +0100

> Rename the rx_machine_lock to state_machine_lock as this makes more
> sense in light of it now protecting all the state machines against
> concurrency.
> 
> Signed-off-by: Nils Carlson <nils.carlson@ericsson.com>

Applied.
