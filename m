From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 05/15] i40e: add a comment on barrier and fix panic
 on reset
Date: Thu, 09 Jan 2014 15:12:24 -0500 (EST)
Message-ID: <20140109.151224.1539252523028219271.davem@davemloft.net>
References: <1389271944-26227-6-git-send-email-jeffrey.t.kirsher@intel.com>
	<52CEB538.50505@cogentembedded.com>
	<20140109091735.00002cf0@unknown>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	mitch.a.williams@intel.com, jesse.brandeburg@intel.com
To: gregory.v.rose@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33511 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753729AbaAIUM2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 15:12:28 -0500
In-Reply-To: <20140109091735.00002cf0@unknown>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>
Date: Thu, 9 Jan 2014 09:17:35 -0800

> Yes, it's apparent that two different internal patches were compressed
> together.  If its unacceptable to do this then I'll speak to Jeff about
> splitting them.

I won't reject the entire pull request on account of this, but please
don't do this in the future.
