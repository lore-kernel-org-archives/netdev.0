From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 15239] New: Problem with network performance
 after a while.
Date: Mon, 08 Feb 2010 14:58:57 -0800 (PST)
Message-ID: <20100208.145857.27251976.davem@davemloft.net>
References: <bug-15239-10286@http.bugzilla.kernel.org/>
	<20100208141537.babeed5f.akpm@linux-foundation.org>
	<201002082351.30629.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	maciej.rutecki@gmail.com
To: rjw@sisk.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58893
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752153Ab0BHW6n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2010 17:58:43 -0500
In-Reply-To: <201002082351.30629.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rafael J. Wysocki" <rjw@sisk.pl>
Date: Mon, 8 Feb 2010 23:51:30 +0100

> On Monday 08 February 2010, Andrew Morton wrote:
>> On Sat, 6 Feb 2010 14:39:46 GMT
>> bugzilla-daemon@bugzilla.kernel.org wrote:
>> 
>> > http://bugzilla.kernel.org/show_bug.cgi?id=15239
>> 
>> post-2.6.32 regression, backported into -stable :(
> 
> Added, CCing netdev.

No need, we already worked on this and have a fix,
see:

http://marc.info/?l=linux-netdev&m=126565759512718&w=2
