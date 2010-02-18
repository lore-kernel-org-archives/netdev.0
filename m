From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] be2net: free tx buffers when completions
 never arrive
Date: Thu, 18 Feb 2010 15:44:36 -0800 (PST)
Message-ID: <20100218.154436.211087999.davem@davemloft.net>
References: <20100218093603.GA28912@serverengines.com>
	<20100218.021616.127015823.davem@davemloft.net>
	<20100218103717.GA15679@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathyap@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37494
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751642Ab0BRXoV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2010 18:44:21 -0500
In-Reply-To: <20100218103717.GA15679@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathyap@serverengines.com>
Date: Thu, 18 Feb 2010 16:07:17 +0530

> 
> On 18/02/10 02:16 -0800, David Miller wrote:
> <snip>
>> > +        bool dummy_wrb;
>> 
>> Some of your lines start with tabs, some with spaces.   You
>> have to use tabs consistently.
>> 
> <snip>
> 
> Sorry, mistake fixed; patch below. Thanks a lot...

Applied.
