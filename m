From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] sysctl:  lockdep support for sysctl reference
 counting.
Date: Mon, 30 Mar 2009 15:26:16 -0700
Message-ID: <20090330152616.7cc2c87c.akpm@linux-foundation.org>
References: <49B91A7E.76E4.0078.0@novell.com>
	<tip-6a09dfa870ba0ed21b1124539968a36b42660661@git.kernel.org>
	<1236934491.5188.209.camel@laptop>
	<49BA33BE.76E4.0078.0@novell.com>
	<1236937423.22914.3698.camel@twins>
	<20090313103828.GB31094@elte.hu>
	<m1d4cd9n4k.fsf@fess.ebiederm.org>
	<20090320085205.GB16021@elte.hu>
	<m14oxo8qis.fsf@fess.ebiederm.org>
	<20090320182404.GA31629@elte.hu>
	<1237575134.4667.5.camel@laptop>
	<1237577688.4667.68.camel@laptop>
	<m1iqm3xr2n.fsf_-_@fess.ebiederm.org>
	<m1eiwrxr05.fsf_-_@fess.ebiederm.org>
	<m1ab7fxqxw.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mingo@elte.hu, jbeulich@novell.com, tglx@linutronix.de,
	mingo@redhat.com, hpa@zytor.com, linux-kernel@vger.kernel.org,
	ego@in.ibm.com, peterz@infradead.org, adobriyan@gmail.com,
	netdev@vger.kernel.org
To: ebiederm@xmission.com (Eric W. Biederman)
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760289AbZC3Wdk@vger.kernel.org>
In-Reply-To: <m1ab7fxqxw.fsf_-_@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


So I merged these two patches.  I designated them as to-be-merged via
Alexey, with a Cc:Peter (IOW: wakey wakey ;))

Regarding this:

> From: ebiederm@xmission.com (Eric W. Biederman)
> ...
> Signed-off-by: Eric Biederman <ebiederm@aristanetworks.com>

It doesn't make a lot of sense to have a different Author: address,
IMO.  So I rewrote the From: address to be ebiederm@aristanetworks.com,
OK?

But it would be better if you were to do this, so please do put an
explicit From: line at the top of your changelogs.
