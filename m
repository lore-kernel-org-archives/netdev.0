From: David Miller <davem@davemloft.net>
Subject: Re: rps perfomance WAS(Re: rps: question
Date: Thu, 15 Apr 2010 01:51:58 -0700 (PDT)
Message-ID: <20100415.015158.58248432.davem@davemloft.net>
References: <1271271222.4567.51.camel@bigi>
	<20100414124426.6aee95c3@nehalam>
	<1271276568.4567.59.camel@bigi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, eric.dumazet@gmail.com, therbert@google.com,
	netdev@vger.kernel.org, robert@herjulf.net, xiaosuo@gmail.com,
	andi@firstfloor.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49441
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757499Ab0DOIvy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Apr 2010 04:51:54 -0400
In-Reply-To: <1271276568.4567.59.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: jamal <hadi@cyberus.ca>
Date: Wed, 14 Apr 2010 16:22:48 -0400

> On Wed, 2010-04-14 at 12:44 -0700, Stephen Hemminger wrote:
> 
>> RPS might also interact with the core turbo boost functionality on Intel chips.
>> Newer chips will make a single core faster if other core can be kept idle.
> 
> how well does it work with Linux?

It's completely transparent and should just happen without any
BIOS tweaks.

