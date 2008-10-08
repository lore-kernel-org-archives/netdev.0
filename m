From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 1/8] sysfs: Implement sysfs tagged directory support.
Date: Wed, 8 Oct 2008 09:00:06 -0400
Message-ID: <20081008130006.GB31684@infradead.org>
References: <dac45060809020654g62afb3c9yd104682b93b43bee@mail.gmail.com> <48BD47A8.1080909@bull.net> <20080902170148.GA9305@suse.de> <31436f4a0809032233r2c46de8od8a94460ce3b5ed2@mail.gmail.com> <48BF83E1.5040000@bull.net> <dac45060810070939v80918a0m3963d7fc6fcbb975@mail.gmail.com> <20081007164833.GA16056@suse.de> <m1abdgywnb.fsf@frodo.ebiederm.org> <20081007210902.GB7996@suse.de> <m18wt0qbwf.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg KH <gregkh@suse.de>, Mark Ryden <markryde@gmail.com>,
	Benjamin Thery <benjamin.thery@bull.net>,
	David Shwatrz <dshwatrz@gmail.com>, Greg KH <greg@kroah.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Tejun Heo <htejun@gmail.com>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	linux-kernel@vger.kernel.org, Al Viro <viro@ftp.linux.org.uk>,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:53183 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752218AbYJHNAs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 09:00:48 -0400
Content-Disposition: inline
In-Reply-To: <m18wt0qbwf.fsf@frodo.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 07, 2008 at 03:27:12PM -0700, Eric W. Biederman wrote:
> Al reviewed sysfs with my patchset on top of it.
> 
> Al's review found problems in  sysfs with my patchset on top of it.
> 
> If you look at what Al found the majority of those problems exist in sysfs
> without my patches.

And when something is crap your fix it firdt before piling up more shit
on top of it.  And sysfs is a really severe case of that, and you're
piling a _lot_ of shit ontop.

