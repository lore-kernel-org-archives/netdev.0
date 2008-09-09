From: Chris Snook <csnook@redhat.com>
Subject: Re: RFC: Nagle latency tuning
Date: Tue, 09 Sep 2008 16:25:36 -0400
Message-ID: <48C6DBC0.6020001@redhat.com>
References: <48C6052D.2080203@redhat.com>	<87zlmhs7we.fsf@basil.nowhere.org>	<48C6C300.4050102@redhat.com> <20080909.125934.150042096.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, rick.jones2@hp.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:41664 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751628AbYIIU2L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Sep 2008 16:28:11 -0400
In-Reply-To: <20080909.125934.150042096.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> Still waiting for your test program and example traces Chris.
> 
> Until I see that there really isn't anything more I can contribute
> concretely to this discussion.

No problem.  Right now I'm working on testing the target workloads with the 
tunables Andi posted, but I'll also work up a trivial test case to demonstrate 
it.  The apps where these problems are being reported are not exactly the sort 
of thing one posts to netdev.

-- Chris
