From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/08]: VLAN update
Date: Mon, 14 Jul 2008 22:56:50 -0700 (PDT)
Message-ID: <20080714.225650.36459474.davem@davemloft.net>
References: <20080709120945.11669.42790.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45996
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753329AbYGOF4t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2008 01:56:49 -0400
In-Reply-To: <20080709120945.11669.42790.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Wed,  9 Jul 2008 14:09:45 +0200 (MEST)

> These patches include an updated set of the VLAN packet socket fixes,
> now also supporting VLAN TCI delivery to userspace using mmaped packet
> sockets, as well as a patch to add ->get_flags ethtool support and
> a few minor cleanup patches.

Applied and pushed out to net-next-2.6, thanks Patrick.
