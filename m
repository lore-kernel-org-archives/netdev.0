From: Christoph Hellwig <hch@infradead.org>
Subject: Re: ipw2100: intrusive cleanups, working this time ;-)
Date: Fri, 13 May 2005 09:21:43 +0100
Message-ID: <20050513082143.GA553@infradead.org>
References: <20050512225026.GA2822@elf.ucw.cz> <4283FA4D.3010208@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pavel Machek <pavel@ucw.cz>, netdev@oss.sgi.com,
        kernel list <linux-kernel@vger.kernel.org>, jbohac@suse.cz,
        jbenc@suse.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: James Ketrenos <jketreno@linux.intel.com>
Content-Disposition: inline
In-Reply-To: <4283FA4D.3010208@linux.intel.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, May 12, 2005 at 07:52:29PM -0500, James Ketrenos wrote:
> Part of the process we have in place is to try and make sure that the
> versions that get picked up by distros and the majority of users have a
> 'known' level of quality.  As part of that, we only want to get changes
> pushed to -mm and eventual mainline that have gone through regression
> testing.

The only wait to make that works is to opensource the testsuites and allow
the distros to run the QA test themselves.  Except for maybe SuSE no one
will pick up a driver version just because you say so.

p.s. please remove the part of the mail you follow up to that's not relevant
	yo your posting.  thanks.
