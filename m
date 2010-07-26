From: David Miller <davem@davemloft.net>
Subject: Re: [net 0/2] Clean up netfilter cache on xmit-to-self.
Date: Sun, 25 Jul 2010 22:01:04 -0700 (PDT)
Message-ID: <20100725.220104.59695038.davem@davemloft.net>
References: <1279828488-17800-1-git-send-email-greearb@candelatech.com>
	<20100725.215912.39197141.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60832
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751759Ab0GZFAr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jul 2010 01:00:47 -0400
In-Reply-To: <20100725.215912.39197141.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Sun, 25 Jul 2010 21:59:12 -0700 (PDT)

> From: Ben Greear <greearb@candelatech.com>
> Date: Thu, 22 Jul 2010 12:54:46 -0700
> 
>> These patches are against 2.6.34.1.  The first one may be
>> worth submitting to stable.  The second one is less critical
>> and should probably just go in the development tree.
> 
> I'll apply the first one to net-2.6 and queue up for -stable
> 
> The second one will go to net-next-2.6

Actually it appears net-next-2.6 already has this change.
