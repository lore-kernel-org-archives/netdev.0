From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 8325] New: -j REDIRECT --to-ports 1000-1009,
 always first choosen
Date: Fri, 13 Apr 2007 14:47:02 -0700
Message-ID: <20070413144702.8ebf1cfe.akpm@linux-foundation.org>
References: <200704132053.l3DKrC9X000466@fire-2.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>, wijata@nec-labs.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:54272 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030852AbXDMVrR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Apr 2007 17:47:17 -0400
In-Reply-To: <200704132053.l3DKrC9X000466@fire-2.osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 13 Apr 2007 13:53:12 -0700
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=8325
> 
>            Summary: -j REDIRECT --to-ports 1000-1009, always first choosen
>     Kernel Version: 2.6.19-1.2911.fc6PAE 2.6.19-gentoo-r4
>             Status: NEW
>           Severity: normal
>              Owner: networking_netfilter-iptables@kernel-bugs.osdl.org
>          Submitter: wijata@nec-labs.com
> 
> 
> Most recent kernel where this bug did *NOT* occur:
> Distribution: FC6, gentoo
> Hardware Environment:
> Software Environment:
> Problem Description:
> 
> Steps to reproduce:
> Try redirecting to range of ports with iptables, kernel(?) will always redirect 
> to first port from given range.
> 
