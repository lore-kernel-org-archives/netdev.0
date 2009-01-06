From: Zdenek Kabelac <zkabelac@redhat.com>
Subject: Re: [BUG] INFO: inconsistent lock state
Date: Tue, 06 Jan 2009 11:18:45 +0100
Message-ID: <49633005.5080305@redhat.com>
References: <4962C322.8000201@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Li Zefan <lizf@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:35674 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750806AbZAFKUx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2009 05:20:53 -0500
In-Reply-To: <4962C322.8000201@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Li Zefan napsal(a):
> I am using Linus' tree, and the top commit is:
> 
> commit fe0bdec68b77020281dc814805edfe594ae89e0f
> Merge: 099e657... 5af75d8...
> Author: Linus Torvalds <torvalds@linux-foundation.org>
> Date:   Sun Jan 4 16:32:11 2009 -0800
> 
>     Merge branch 'audit.b61' of git://git.kernel.org/pub/scm/linux/kernel/git/viro/audit-current
> 
> don't know how I triggered this, and not sure whom to CC, network related?
> 

I've got the similar one too: http://lkml.org/lkml/2009/1/3/55

Zdenek
