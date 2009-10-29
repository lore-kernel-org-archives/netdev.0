From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] net: allow netdev_wait_allrefs() to run faster
Date: Thu, 29 Oct 2009 16:07:18 -0700
Message-ID: <m1d445yf2x.fsf@fess.ebiederm.org>
References: <20091017221857.GG1925@kvack.org> <4ADB55BC.5020107@gmail.com>
	<20091018182144.GC23395@kvack.org>
	<200910211539.01824.opurdila@ixiacom.com> <4ADF2B57.4030708@gmail.com>
	<20091021165139.GL877@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Octavian Purdila <opurdila@ixiacom.com>,
	netdev@vger.kernel.org, Cosmin Ratiu <cratiu@ixiacom.com>
To: Benjamin LaHaise <bcrl@lhnet.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:50994 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752616AbZJ2XHU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 19:07:20 -0400
In-Reply-To: <20091021165139.GL877@kvack.org> (Benjamin LaHaise's message of "Wed\, 21 Oct 2009 12\:51\:39 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Benjamin LaHaise <bcrl@lhnet.ca> writes:

> On Wed, Oct 21, 2009 at 05:40:07PM +0200, Eric Dumazet wrote:
>> Ben patch only address interface deletion, and one part of the problem,
>> maybe the more visible one for the current kernel.
>
> The first part I've been tackling has been the overhead in procfs, sysctl 
> and sysfs.  

Could you keep me in the loop with that.  I have some pending cleanups for
all of those pieces of code and may be able to help/advice/review.

Eric
