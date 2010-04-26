From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] RCU: don't turn off lockdep when find suspicious rcu_dereference_check() usage
Date: Mon, 26 Apr 2010 11:35:10 -0700
Message-ID: <m1hbmydpup.fsf@fess.ebiederm.org>
References: <t2la44ae5cd1004200838w87256e80v9dcde91342b321db@mail.gmail.com>
	<20100421213543.GO2563@linux.vnet.ibm.com>
	<20100422145640.GB3228@redhat.com>
	<20100422160144.GC2524@linux.vnet.ibm.com>
	<h2xa44ae5cd1004230550uf734c89eo2b1d1945d446068c@mail.gmail.com>
	<20100423194255.GE2589@linux.vnet.ibm.com>
	<m2xa44ae5cd1004231559hcf90671asf146a43b4748c2c3@mail.gmail.com>
	<20100425023455.GM2440@linux.vnet.ibm.com>
	<w2sa44ae5cd1004250849q73704370vc6af935c70db9b73@mail.gmail.com>
	<p2ga44ae5cd1004251320j55d23ba7ua0fa14497f623d76@mail.gmail.com>
	<20100426160925.GD2529@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Miles Lane <miles.lane@gmail.com>, Vivek Goyal <vgoyal@redhat.com>,
	Eric Paris <eparis@redhat.com>,
	Lai Jiangshan <laijs@cn.fujitsu.com>,
	Ingo Molnar <mingo@elte.hu>,
	Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>, nauman@google.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	Jens Axboe <jens.axboe@oracle.com>,
	Gui Jianfeng <guijianfeng@cn.fujitsu.com>,
	Li Zefan <lizf@cn.fujitsu.com>,
	Johannes Berg <johannes@sipsolutions.net>
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:45795 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754326Ab0DZSfU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Apr 2010 14:35:20 -0400
In-Reply-To: <20100426160925.GD2529@linux.vnet.ibm.com> (Paul E. McKenney's message of "Mon\, 26 Apr 2010 09\:09\:25 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Paul E. McKenney" <paulmck@linux.vnet.ibm.com> writes:

> Eric Dumazet traced these down to a commit from Eric Biederman.
>
> If I don't hear from Eric Biederman in a few days, I will attempt a
> patch, but it would be more likely to be correct coming from someone
> with a better understanding of the code.  ;-)

I already replied.

http://lkml.org/lkml/2010/4/21/420

Eric
