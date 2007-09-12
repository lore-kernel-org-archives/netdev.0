From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 1/4] [IPROUTE2] Revert "Make ip utility veth driver aware"
Date: Wed, 12 Sep 2007 07:48:20 -0600
Message-ID: <m1zlzs9eqj.fsf@ebiederm.dsl.xmission.com>
References: <m14pi0cac5.fsf@ebiederm.dsl.xmission.com>
	<46E7E1BF.6070108@openvz.org>
	<m1ejh4av4j.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:60695 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965681AbXILNsv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 09:48:51 -0400
In-Reply-To: <m1ejh4av4j.fsf@ebiederm.dsl.xmission.com> (Eric W. Biederman's
	message of "Wed, 12 Sep 2007 07:09:00 -0600")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ebiederm@xmission.com (Eric W. Biederman) writes:

> Pavel Emelyanov <xemul@openvz.org> writes:
>
>> Eric W. Biederman wrote:
>>> Stephen it looks like you weren't cc'd on the latest version
>>> of the veth support.  So this patchset first reverts the old
>>
>> He was. The latest version looks completely different from what
>> is reversed in this patch.
>
> This is against the latest snapshot I could find.  My apologies
> if I missed some of the communication.

I was working against:
git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git

And the last I could find of the conversation about veth support was
in the thread announcing iproute-2-2.6.23-rc3, and Stephen Hemminger
asking for the latest version of the veth support to be sent on
Sept 1st.

So it is quite possible this has been resolved in private email,
and nothing public has been updated yet.

I just don't have a copy of anything newer, and I don't know where else
I would look for something newer.  So since I'm starting to use veth
I sent the patches I had to make it work.

The last round of veth support for iproute2 I could find was sent
on the 19th of July and David Miller, Patrick McHardy, and netdev
were copied but Stephen Hemminger wasn't.  Which is where my
assertion that Stephen hadn't been sent the latest version came from.

If you guys have already sorted this out and I just can't find the
code I'm overjoyed.  Otherwise the patches I sent should be enough
to get things sorted out, if I have figure out the current state of
confusion.

Eric
