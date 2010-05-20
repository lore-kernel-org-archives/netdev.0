From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 0/6] tagged sysfs support
Date: Thu, 20 May 2010 10:47:43 -0700
Message-ID: <20100520174743.GA17077@kroah.com>
References: <m1fx3hk6gw.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Kroah-Hartman <gregkh@suse.de>,
	Kay Sievers <kay.sievers@vrfy.org>,
	linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>,
	Cornelia Huck <cornelia.huck@de.ibm.com>,
	linux-fsdevel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Benjamin LaHaise <bcrl@lhnet.ca>,
	Serge Hallyn <serue@us.ibm.com>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m1fx3hk6gw.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 30, 2010 at 11:30:23AM -0700, Eric W. Biederman wrote:
> 
> The main short coming of using multiple network namespaces today
> is that only network devices for the primary network namespaces
> can be put in the kobject layer and sysfs.
> 
> This is essentially the earlier version of this patchset that was
> reviewed before, just now on top of a version of sysfs that doesn't
> need cleanup patches to support it.
> 
> I have been running these patches in some form for well over a
> year so the basics should at least be solid.  
> 
> This patchset is currently against 2.6.34-rc1.
> 
> This patchset is just the basic infrastructure a couple of more pretty
> trivial patches are needed to actually enable network namespaces to use this.
> My current plan is to send those after these patches have made it through
> review.

All queued up now.

thanks,

greg k-h
