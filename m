From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH]: Dynamically sized routing cache hash table.
Date: Tue, 06 Mar 2007 01:05:23 -0800 (PST)
Message-ID: <20070306.010523.15263796.davem@davemloft.net>
References: <45ED14E6.7090109@cosmosbay.com>
	<20070305.232329.95506510.davem@davemloft.net>
	<45ED1F35.4070600@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, robert.olsson@its.uu.se, npiggin@suse.de
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44858
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933079AbXCFJF1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 04:05:27 -0500
In-Reply-To: <45ED1F35.4070600@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Tue, 06 Mar 2007 08:58:45 +0100

> Yes, but on bootup you have an appropriate NUMA active policy. (Well... we 
> hope so, but it broke several time in the past)
> I am not sure what kind of mm policy is active for scheduled works.

Good point, that definitely needs investigation.

Thanks for all of your comments so far Eric, very useful :)
