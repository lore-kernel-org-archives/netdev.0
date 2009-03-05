From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] 2.6.29-rc* QinQ vlan trunking regression
Date: Wed, 04 Mar 2009 23:11:20 -0800 (PST)
Message-ID: <20090304.231120.86999183.davem@davemloft.net>
References: <20090304.225719.159854470.davem@davemloft.net>
	<20090304.230023.09984572.davem@davemloft.net>
	<49AF79A6.6030002@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bart@jukie.net, greearb@candelatech.com, shemminger@vyatta.com,
	dada1@cosmosbay.com, frank.blaschka@de.ibm.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57546
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751933AbZCEHLg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2009 02:11:36 -0500
In-Reply-To: <49AF79A6.6030002@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 05 Mar 2009 08:05:10 +0100

> David Miller wrote:
> > I think this will fix it.
> 
> Good catch, that looks like a likely cause. Will test in a minute ...

We probably need both fixes to cover everything.
