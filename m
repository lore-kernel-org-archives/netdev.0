From: Petr Baudis <pasky@ucw.cz>
Subject: Re: git repository for net drivers available
Date: Sun, 15 May 2005 22:05:14 +0200
Message-ID: <20050515200514.GA31414@pasky.ji.cz>
References: <42841A3F.7020909@pobox.com> <4284C54E.3060907@linux.intel.com> <4284C7DA.1020707@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Ketrenos <jketreno@linux.intel.com>,
	Netdev <netdev@oss.sgi.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	git@vger.kernel.org
Return-path: <git-owner@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <4284C7DA.1020707@pobox.com>
Sender: git-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear diary, on Fri, May 13, 2005 at 05:29:30PM CEST, I got a letter
where Jeff Garzik <jgarzik@pobox.com> told me that...
> Looks like cogito is using $repo/heads/$branch, whereas my git repo is 
> using $repo/branches/$branch.

Would it be a big problem to use refs/heads/$branch? That's the
currently commonly agreed convention about location for storing branch
heads, not just some weird Cogito-specific invention. And it'd be very
nice to have those locations consistent across git repositories.

Thanks,

-- 
				Petr "Pasky" Baudis
Stuff: http://pasky.or.cz/
C++: an octopus made by nailing extra legs onto a dog. -- Steve Taylor
