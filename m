From: Patrick Schaaf <bof@bof.de>
Subject: Re: TODO list before feature freeze
Date: Tue, 30 Jul 2002 15:06:39 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020730150639.B492@oknodo.bof.de>
References: <20020730142758.A492@oknodo.bof.de> <Pine.GSO.4.30.0207300818480.15727-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick Schaaf <bof@bof.de>, Andi Kleen <ak@suse.de>,
   Rusty Russell <rusty@rustcorp.com.au>, netfilter-devel@lists.netfilter.org,
   netdev@oss.sgi.com, netfilter-core@lists.netfilter.org
Return-path: <owner-netdev@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <Pine.GSO.4.30.0207300818480.15727-100000@shell.cyberus.ca>; from hadi@cyberus.ca on Tue, Jul 30, 2002 at 08:29:49AM -0400
List-Id: netdev.vger.kernel.org

> Hashing is an issue, no doubt but i dont think it is the main issue.

I fully agree. I mention this all the time.

> Did you start chasing hashing because you saw some large numbers
> in profiles?

No. I looked at the hash function and bucket sizes, because I now have
machines in the field running conntrack, and I wanted to understand
how I should chose an appropriate size. So I took real world conntrack
snapshots on those machines, and analysed. I learned all there is to
learn about the question, and present the results for others to use
like they see fit. End of story.

Again, I have no performance trouble with conntracking on any of my
production systems.

best regards
  Patrick

-- 
everything is under control.
	(Hardware)
