From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: git repository for net drivers available
Date: Sun, 15 May 2005 16:20:50 -0400
Message-ID: <4287AF22.8090300@pobox.com>
References: <42841A3F.7020909@pobox.com> <4284C54E.3060907@linux.intel.com> <4284C7DA.1020707@pobox.com> <20050515200514.GA31414@pasky.ji.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: James Ketrenos <jketreno@linux.intel.com>,
	Netdev <netdev@oss.sgi.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	git@vger.kernel.org, Andrew Morton <akpm@osdl.org>
Return-path: <git-owner@vger.kernel.org>
To: Petr Baudis <pasky@ucw.cz>
In-Reply-To: <20050515200514.GA31414@pasky.ji.cz>
Sender: git-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Petr Baudis wrote:
> Dear diary, on Fri, May 13, 2005 at 05:29:30PM CEST, I got a letter
> where Jeff Garzik <jgarzik@pobox.com> told me that...
> 
>>Looks like cogito is using $repo/heads/$branch, whereas my git repo is 
>>using $repo/branches/$branch.
> 
> 
> Would it be a big problem to use refs/heads/$branch? That's the
> currently commonly agreed convention about location for storing branch
> heads, not just some weird Cogito-specific invention. And it'd be very
> nice to have those locations consistent across git repositories.

Sure, that's doable.

I've pushed out this change to kernel.org.

	Jeff



