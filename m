From: Andi Kleen <ak@suse.de>
Subject: Re: TODO list before feature freeze
Date: Mon, 29 Jul 2002 18:31:16 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020729183116.B27940@wotan.suse.de>
References: <20020729131239.A5183@wotan.suse.de> <Pine.GSO.4.30.0207290719580.12604-100000@shell.cyberus.ca> <20020729182659.D570@oknodo.bof.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamal <hadi@cyberus.ca>, Andi Kleen <ak@suse.de>,
   Rusty Russell <rusty@rustcorp.com.au>, netfilter-devel@lists.netfilter.org,
   netdev@oss.sgi.com, netfilter-core@lists.netfilter.org
Return-path: <owner-netdev@oss.sgi.com>
To: Patrick Schaaf <bof@bof.de>
Content-Disposition: inline
In-Reply-To: <20020729182659.D570@oknodo.bof.de>
List-Id: netdev.vger.kernel.org

> Regarding the hashing schemes, please see discussions on netfilter-devel
> over the last weeks:
> 
> http://lists.netfilter.org/pipermail/netfilter-devel/2002-July/thread.html
> 
> and a small presentation of various bucket sizes / hash functions
> for some real world scenarios: http://bei.bof.de/ex6/
> This presentation, a bit terse on comments, links to a tarball
> which allows you to recreate the same presentation for any
> dump of /proc/net/ip_conntrack, varying bucket counts and
> hash functions.

Have you done any profiling of real workloads to see where the actual 
overhead comes from?

-Andi
