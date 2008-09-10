From: Chris Snook <csnook@redhat.com>
Subject: Re: [PATCH 3/4] atlx: add atl2.c
Date: Tue, 09 Sep 2008 22:16:54 -0400
Message-ID: <48C72E16.7050509@redhat.com>
References: <20080909061247.GA17834@file.rdu.redhat.com>	<20080909062213.GC18425@file.rdu.redhat.com> <20080909204413.745b43e7@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	atl2-test@lists.sourceforge.net
To: Jay Cliburn <jcliburn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:55436 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751529AbYIJCU0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Sep 2008 22:20:26 -0400
In-Reply-To: <20080909204413.745b43e7@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Cliburn wrote:
> On Tue, 9 Sep 2008 02:22:13 -0400
> Chris Snook <csnook@redhat.com> wrote:
> 
>> From: Chris Snook <csnook@redhat.com>
>>
>> Add the atl2 implementation.
>>
>> Signed-off-by: Chris Snook <csnook@redhat.com>
> 
> Checkpatch.pl reports coding style and whitespace issues.
> 
> total: 179 errors, 55 warnings, 3101 lines checked

As with atl2.h, this is expected.  Most of this be taken care of when we unify 
the atl1 and atl2 code into the atlx code, and the rest will be short work.

We can do a lot of cosmetic cleanup before 2.6.28 is released, but I think it's 
important we get this into linux-next (and later the -git kernels) and get more 
widespread functional testing before that happens.

-- Chris
