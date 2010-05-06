From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 0/6] netns support in the kobject layer
Date: Thu, 6 May 2010 13:04:04 -0700
Message-ID: <20100506200404.GA21805@kroah.com>
References: <m1fx3hk6gw.fsf@fess.ebiederm.org>
 <m1d3xb4239.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Kroah-Hartman <gregkh@suse.de>,
	Kay Sievers <kay.sievers@vrfy.org>,
	linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>,
	Cornelia Huck <cornelia.huck@de.ibm.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Benjamin LaHaise <bcrl@lhnet.ca>,
	Serge Hallyn <serue@us.ibm.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m1d3xb4239.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 04, 2010 at 05:35:54PM -0700, Eric W. Biederman wrote:
> 
> With the tagged sysfs support finally merged into Greg's tree,
> it is time for the last little bits of work to get the kobject
> layer and network namespaces to play together properly.
> 
> These patches are roughly evenly divided between network layer work
> and sysfs layer work.  Last time this conundrum came up I believe
> we decided that the easiest way to handle this was for Greg to carry
> all of the patches.  David, Greg does that still make sense?

That's fine, if I get David's ack on these.

thanks,

greg k-h
