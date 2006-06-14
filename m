From: Chase Venters <chase.venters@clientec.com>
Subject: Re: [RFC/PATCH 1/2] in-kernel sockets API
Date: Tue, 13 Jun 2006 19:29:19 -0500
Message-ID: <200606131929.41985.chase.venters@clientec.com>
References: <1150156562.19929.32.camel@w-sridhar2.beaverton.ibm.com> <200606131906.16683.chase.venters@clientec.com> <20060613181801.A8460@openss7.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
	Daniel Phillips <phillips@google.com>,
	Stephen Hemminger <shemminger@osdl.org>,
	Sridhar Samudrala <sri@us.ibm.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay01.pair.com ([209.68.5.15]:15371 "HELO relay01.pair.com")
	by vger.kernel.org with SMTP id S932329AbWFNA3n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2006 20:29:43 -0400
To: bidulock@openss7.org
In-Reply-To: <20060613181801.A8460@openss7.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 13 June 2006 19:17, Brian F. G. Bidulock wrote:
> Chase,
>
> On Tue, 13 Jun 2006, Chase Venters wrote:
> > I'm trying to imagine what kind of legitimate non-GPL modules might
> > use them.
>
> Example: in-kernel RTP implementation derived from AT&T rtp-lib
> implementation (non-GPL compatible license) utilizing this kernel
> interface for UDP socket access.

I don't mean to be obtuse, but the "Non-exclusive Non-commercial Limited-use 
Source" license seems to make something like that have limited usefulness in 
general. That is -- unless one were to obtain a commercial license from AT&T, 
but then that starts falling into the domain of what is likely prohibited by 
the GPL (some sort of proprietary work actually _derived_ off the kernel 
rather than just supporting it in some way).

But I did ask for examples...

Thanks,
Chase
