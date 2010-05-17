From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/6] netns support in the kobject layer
Date: Mon, 17 May 2010 16:48:21 -0700 (PDT)
Message-ID: <20100517.164821.189684939.davem@davemloft.net>
References: <20100517181133.GB18721@kroah.com>
	<m1zkzyfdob.fsf@fess.ebiederm.org>
	<20100517210318.GA6170@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, greg@kroah.com, kay.sievers@vrfy.org,
	linux-kernel@vger.kernel.org, tj@kernel.org,
	cornelia.huck@de.ibm.com, eric.dumazet@gmail.com, bcrl@lhnet.ca,
	serue@us.ibm.com, netdev@vger.kernel.org
To: gregkh@suse.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100517210318.GA6170@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Greg KH <gregkh@suse.de>
Date: Mon, 17 May 2010 14:03:18 -0700

> On Mon, May 17, 2010 at 01:58:44PM -0700, Eric W. Biederman wrote:
>> Greg KH <greg@kroah.com> writes:
>> 
>> If I must I will resend these, but these patches are already in
>> production use, and I had them to you weeks before the merge window
>> closed.
> 
> Yes, but they were not reviewed by the network maintainer until after
> the merge window closed.  I already have your sysfs-namespace patches
> queued up for .35, and that's a big enough change for me to feel
> comfortable with at the moment.

Greg, this is complete bullshit.  I reviewed them last week, they are fine
and have been around forever.

Merge them in now, making them wait until 2.6.36 is completely rediculious.
