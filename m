From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH] Add xfrm policy change auditing to pfkey_spdget
Date: Thu, 8 Mar 2007 15:08:04 -0500
Message-ID: <200703081508.04186.paul.moore@hp.com>
References: <1172861484.31047.26.camel@localhost.localdomain> <20070307.160740.77057241.davem@davemloft.net> <1173370815.31047.134.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Paris <eparis@parisplace.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:45238 "EHLO atlrel8.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752627AbXCHUIR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Mar 2007 15:08:17 -0500
In-Reply-To: <1173370815.31047.134.camel@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday, March 8 2007 11:20:15 am Eric Paris wrote:
> I lose at using git.  Sorry.  I'll be more careful to check that all of
> my changes on the current branch are committed before I run my git diff.
> Or maybe someone will convince me to use git in an all new better way.

[NOTE: I stripped a lot of addresses from this mail as I suspect it to be 
somewhat off-topic]

Perhaps not quite what you were asking for, but I've found quilt[1] to be an 
*extremely* wonderful tool for creating and manipulating patches to send 
upstream.  It doesn't replace git, you still need it to fetch/update the 
source tree, but it plays well with git (there is the "stacked git" project 
which aims to integrate the two bits of software but I have never tried it).

[1] http://savannah.nongnu.org/projects/quilt

-- 
paul moore
linux security @ hp
