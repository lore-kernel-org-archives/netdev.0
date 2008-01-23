From: David Miller <davem@davemloft.net>
Subject: Re: [NET_SCHED 00/06]: Conversion to new netlink API
Date: Tue, 22 Jan 2008 22:12:19 -0800 (PST)
Message-ID: <20080122.221219.254390574.davem@davemloft.net>
References: <20080122145542.6862.23693.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45663
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753369AbYAWGMK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2008 01:12:10 -0500
In-Reply-To: <20080122145542.6862.23693.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Tue, 22 Jan 2008 15:56:08 +0100 (MET)

> These patches convert the packet schedulers to the new netlink API.
> This will allow to use the new features like automatic attribute
> checking and gets rid of the largest rtnetlink.h user we still have.
> Unfortunately a gradual conversion is not really feasible, so the
> patches are quite large, but most of them has been generated
> automatically, so I'm pretty sure they are correct and didn't miss
> anything. Also included are some minor unrelated cleanups I had
> queued in the same tree.
> 
> Please apply, thanks.

Looks good applied, thanks Patrick!
