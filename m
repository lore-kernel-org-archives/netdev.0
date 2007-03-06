From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC] div64_64 support
Date: Tue, 6 Mar 2007 15:45:29 +0100
Message-ID: <20070306144529.GA2004@one.firstfloor.org>
References: <20070223170527.4ca695b2@freekitty> <20070305155714.3abe1b5e@freekitty> <20070306133404.GA864@one.firstfloor.org> <200703061519.20346.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Jan Engelhardt <jengelh@linux01.gwdg.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:33192 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965094AbXCFOpd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 09:45:33 -0500
Content-Disposition: inline
In-Reply-To: <200703061519.20346.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> <rant>
> Let me see... You throw code like that and expect someone to actually 
> understand it in one year, and be able to correct a bug ?

To be honest I don't expect any bugs in this function.

> </rant>
> 
> Please add something, an URL or even better a nice explanation, per favor...

It's straight out of Hacker's delight which is referenced in the commit
log.

-Andi
