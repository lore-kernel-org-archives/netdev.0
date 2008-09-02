From: Greg KH <gregkh@suse.de>
Subject: Re: [PATCH 1/8] sysfs: Implement sysfs tagged directory support.
Date: Tue, 2 Sep 2008 10:01:48 -0700
Message-ID: <20080902170148.GA9305@suse.de>
References: <m18wwiihbn.fsf_-_@frodo.ebiederm.org> <m14p76ih9a.fsf_-_@frodo.ebiederm.org> <m1zloyh2mb.fsf_-_@frodo.ebiederm.org> <m1vdzmh2jr.fsf_-_@frodo.ebiederm.org> <20080820021754.GA25182@kroah.com> <m1od3m282j.fsf_-_@frodo.ebiederm.org> <m1hc9e27ya.fsf_-_@frodo.ebiederm.org> <48B57058.9000101@bull.net> <dac45060809020654g62afb3c9yd104682b93b43bee@mail.gmail.com> <48BD47A8.1080909@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg KH <greg@kroah.com>, Mark Ryden <markryde@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Tejun Heo <htejun@gmail.com>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	linux-kernel@vger.kernel.org, Al Viro <viro@ftp.linux.org.uk>,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org
To: Benjamin Thery <benjamin.thery@bull.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1.suse.de ([195.135.220.2]:50108 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751578AbYIBRGo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Sep 2008 13:06:44 -0400
Content-Disposition: inline
In-Reply-To: <48BD47A8.1080909@bull.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 02, 2008 at 04:03:20PM +0200, Benjamin Thery wrote:
> Mark Ryden wrote:
>> Hello,
>>  I hope that this patch (from 4.7.08) was not forgetten... I don't see
>> it for example in linux-net (I have an up-to-date linux-next git
>> tree).
>
> I was about to ask the same thing.
>
> Greg, what is the plan with these remaining patches for sysfs tagged
> dirs? Will you have some time to merge them in your tree soon?

Yes, they should go into my tree this week, sorry been busy with 2.6.27
work and Novell's Hackweek.

thanks,

greg k-h
