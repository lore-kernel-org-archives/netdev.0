From: David Miller <davem@davemloft.net>
Subject: Re: 3x59x-fix-pci-resource-management.patch
Date: Wed, 12 Aug 2009 17:26:35 -0700 (PDT)
Message-ID: <20090812.172635.39275627.davem@davemloft.net>
References: <20090806154223.b9b9759e.akpm@linux-foundation.org>
	<4A7C079D.8010505@ru.mvista.com>
	<20090807091415.6a78af4d.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sshtylyov@ru.mvista.com, klassert@mathematik.tu-chemnitz.de,
	netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33514
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750979AbZHMA0Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2009 20:26:25 -0400
In-Reply-To: <20090807091415.6a78af4d.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Fri, 7 Aug 2009 09:14:15 -0700

> On Fri, 07 Aug 2009 14:53:17 +0400 Sergei Shtylyov <sshtylyov@ru.mvista.com> wrote:
> 
>>     There was several more comments from you but they all got resolved 
>> between you and Jeff at the time...
>> 
> 
> Doh, OK, thanks.  My fault.
> 
> I have a cardbus card somewhere..

Please repost this when we have at least some cardbus
testing of some sort, because if we can get rid of all
of that resource special casing that would be nice.
