From: David Miller <davem@davemloft.net>
Subject: Re: [NET_SCHED 00/15]: Make use of new netlink API features
Date: Wed, 23 Jan 2008 20:37:08 -0800 (PST)
Message-ID: <20080123.203708.22525163.davem@davemloft.net>
References: <20080123163555.6459.69501.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34829
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752850AbYAXEg6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2008 23:36:58 -0500
In-Reply-To: <20080123163555.6459.69501.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 23 Jan 2008 17:36:35 +0100 (MET)

> these patches change the packet schedulers/classifers/actions to make use
> of the features of the new netlink API, like typeful attribute dumping and
> parsing, automatic basic attribute validation etc. The also fix a bug and
> a warning introduced by my last set of patches.
> 
> Please apply, thanks.

All applied, thanks for doing this work Patrick.
