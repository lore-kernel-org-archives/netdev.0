From: Berck Nash <flyboy@gmail.com>
Subject: Re: sky2 panic in 2.6.32.1 under load
Date: Thu, 24 Dec 2009 09:16:03 -0700
Message-ID: <4B3393C3.7050408@gmail.com>
References: <4B300A2A.8040305@gmail.com> <20091223225855.4a7d00af.akpm@linux-foundation.org> <4B339290.60909@majjas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>
To: Michael Breuer <mbreuer@majjas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f176.google.com ([209.85.211.176]:64586 "EHLO
	mail-yw0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752915AbZLXQQF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Dec 2009 11:16:05 -0500
In-Reply-To: <4B339290.60909@majjas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael Breuer wrote:
>>> Since 2.6.32, I've been getting kernel panics under heavy network load
>>> (bittorrent usage).
>>>      
>> Let's cc the right list and developer.
>>
>> This is a 2.6.31->2.6.32 regression?
>>    
> I don't think so. I saw this on 2.6.31 - first kernel I put on this
> system. At the time, I was having issues with intel_iommu and thought
> that the culprit.
> The initial reply to this thread from Daniel Hazelton stated that this
> has been happening since 2.6.25.

Your oops appears to be different than mine.  Hazelton did not provide
any logs, and he said "a version of this" so I don't know if his is the
same or not.
