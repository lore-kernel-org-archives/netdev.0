From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: [PATCH] 2.6.25-rc4 de_stop_rxtx polling wrong
Date: Fri, 28 Mar 2008 20:47:03 -0600
Message-ID: <20080329024703.GA8119@colo.lackof.org>
References: <20080309013316.GD25083@colo.lackof.org> <47DE605F.1060100@garzik.org> <20080324050933.GA9944@colo.lackof.org> <47ED6B07.5000101@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Grant Grundler <grundler@parisc-linux.org>, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from colo.lackof.org ([198.49.126.79]:43275 "EHLO colo.lackof.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753286AbYC2CrQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 22:47:16 -0400
Content-Disposition: inline
In-Reply-To: <47ED6B07.5000101@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 28, 2008 at 06:02:47PM -0400, Jeff Garzik wrote:
...
>>> Please include comments like "Jeff," and "Patch was originally[...]" 
>>> after the "---" separator, so that the automated tools may omit these 
>>> comments without human intervention.
>> Which separator is that? I didn't explicitly add one unless you are
>> referring to the patch itself.
>
> See #14 of Documentation/SubmittingPatches.

Wow...this document got a rewrite since the last time I read it.
Thanks for pointing it out. I'll follow that on future patches.


> Basically, anything after "---" in the email body (except for the patch 
> content itself) is intentionally ignored -- and thus is used for comments 
> like "Jeff, quit sitting on your ass and apply this damned patch" that are 
> relevant but do not belong in the permanent kernel history.

*nod*

...
> git-am, Linus's tool that many of us git'ers use for importing patches from 
> email.

Ok - will read the man page for that too.

cheers,
grant
