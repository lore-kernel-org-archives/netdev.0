From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 2/2] sysctl:  lockdep support for sysctl reference counting.
Date: Mon, 30 Mar 2009 15:53:04 -0700
Message-ID: <m1k566k4hb.fsf@fess.ebiederm.org>
References: <49B91A7E.76E4.0078.0@novell.com>
	<tip-6a09dfa870ba0ed21b1124539968a36b42660661@git.kernel.org>
	<1236934491.5188.209.camel@laptop> <49BA33BE.76E4.0078.0@novell.com>
	<1236937423.22914.3698.camel@twins> <20090313103828.GB31094@elte.hu>
	<m1d4cd9n4k.fsf@fess.ebiederm.org> <20090320085205.GB16021@elte.hu>
	<m14oxo8qis.fsf@fess.ebiederm.org> <20090320182404.GA31629@elte.hu>
	<1237575134.4667.5.camel@laptop> <1237577688.4667.68.camel@laptop>
	<m1iqm3xr2n.fsf_-_@fess.ebiederm.org>
	<m1eiwrxr05.fsf_-_@fess.ebiederm.org>
	<m1ab7fxqxw.fsf_-_@fess.ebiederm.org>
	<20090330152616.7cc2c87c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mingo@elte.hu, jbeulich@novell.com, tglx@linutronix.de,
	mingo@redhat.com, hpa@zytor.com, linux-kernel@vger.kernel.org,
	ego@in.ibm.com, peterz@infradead.org, adobriyan@gmail.com,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:35603 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752355AbZC3WxR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2009 18:53:17 -0400
In-Reply-To: <20090330152616.7cc2c87c.akpm@linux-foundation.org> (Andrew Morton's message of "Mon\, 30 Mar 2009 15\:26\:16 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton <akpm@linux-foundation.org> writes:

> So I merged these two patches.  I designated them as to-be-merged via
> Alexey, with a Cc:Peter (IOW: wakey wakey ;))

It is more sysctl than proc but whichever.  As long as people aren't
blind sided at the last minute I'm fine.

> Regarding this:
>
>> From: ebiederm@xmission.com (Eric W. Biederman)
>> ...
>> Signed-off-by: Eric Biederman <ebiederm@aristanetworks.com>
>
> It doesn't make a lot of sense to have a different Author: address,
> IMO.  So I rewrote the From: address to be ebiederm@aristanetworks.com,
> OK?

>From my perspective it does.  It is much easier to use my personal
email setup for doing kernel work.  But I need to indicate I am
signing off as an employee of AristaNetworks.  Saying aristanetworks
in my signed-off-by seems a little more official.

Eric

