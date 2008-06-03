From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 01/05] smc911x: Remove unused 8-bit I/O operations
Date: Tue, 03 Jun 2008 19:20:15 -0400
Message-ID: <4845D1AF.8010904@garzik.org>
References: <20080602113706.28716.92046.sendpatchset@rx1.opensource.se>	<20080602113714.28716.10248.sendpatchset@rx1.opensource.se> <20080603154834.428d89cc.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Magnus Damm <magnus.damm@gmail.com>, netdev@vger.kernel.org,
	lethal@linux-sh.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48192 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751401AbYFCXUX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jun 2008 19:20:23 -0400
In-Reply-To: <20080603154834.428d89cc.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote:
> On Mon, 02 Jun 2008 20:37:14 +0900
> Magnus Damm <magnus.damm@gmail.com> wrote:
> 
>> From: Magnus Damm <magnus.damm@gmail.com>
>> ...
>> Signed-off-by: Magnus Damm <damm@igel.co.jp>
> 
> It's a bit strange to have the Author: line using one email address and
> the s-o-b using a different one. (It's fairly common though).
> 
> It is fixable by putting the desired From: address right at the top of
> the changelog, in the email body.

FWIW, I tend to think it's useful...  I like to use @redhat.com 
sign-offs because I'm working on behalf of red hat, but for all non-NDA 
email I use an account that doesn't depend on my employer.

Because of the potential for unintended info leakage these days, 
corporate email access is reclaimed the minute you leave a company.  It 
isn't wise to depend on the corporate email account.

That's why I patiently and kindly ask people to email me at the 
addresses I've always used for open source (jgarzik@pobox, jeff@garzik). 
  Open conversations don't need to get locked in a corporate tomb :)

	Jeff




