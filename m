From: Li Zefan <lizf@cn.fujitsu.com>
Subject: Re: [BUG] INFO: inconsistent lock state
Date: Tue, 06 Jan 2009 18:25:33 +0800
Message-ID: <4963319D.8040204@cn.fujitsu.com>
References: <4962C322.8000201@cn.fujitsu.com> <49633005.5080305@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Zdenek Kabelac <zkabelac@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:64567 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751373AbZAFK0d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2009 05:26:33 -0500
In-Reply-To: <49633005.5080305@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Zdenek Kabelac wrote:
> Li Zefan napsal(a):
>> I am using Linus' tree, and the top commit is:
>>
>> commit fe0bdec68b77020281dc814805edfe594ae89e0f
>> Merge: 099e657... 5af75d8...
>> Author: Linus Torvalds <torvalds@linux-foundation.org>
>> Date:   Sun Jan 4 16:32:11 2009 -0800
>>
>>     Merge branch 'audit.b61' of
>> git://git.kernel.org/pub/scm/linux/kernel/git/viro/audit-current
>>
>> don't know how I triggered this, and not sure whom to CC, network
>> related?
>>
> 
> I've got the similar one too: http://lkml.org/lkml/2009/1/3/55
> 

So your box freezed and can do nothing but reset ?

I was much luckier that this bug didn't do any harm to my box. :)

