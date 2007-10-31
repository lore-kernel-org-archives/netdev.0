From: Gregory Haskins <gregory.haskins.ml@gmail.com>
Subject: Re: [PATCH 00/33] Swap over NFS -v14
Date: Wed, 31 Oct 2007 09:44:18 -0400
Message-ID: <472886B2.1060207@gmail.com>
References: <20071030160401.296770000@chello.nl>	 <200710311426.33223.nickpiggin@yahoo.com.au>	 <1193830033.27652.159.camel@twins>  <47287220.8050804@garzik.org> <1193835413.27652.205.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>,
	Nick Piggin <nickpiggin@yahoo.com.au>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fys.uio.no
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.249]:39544 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756719AbXJaNob (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2007 09:44:31 -0400
Received: by an-out-0708.google.com with SMTP id b36so13939ana
        for <netdev@vger.kernel.org>; Wed, 31 Oct 2007 06:44:31 -0700 (PDT)
In-Reply-To: <1193835413.27652.205.camel@twins>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Peter Zijlstra wrote:

> 
> But please, people who want this (I'm sure some of you are reading) do
> speak up. I'm just the motivated corporate drone implementing the
> feature :-)

FWIW, I could have used a "swap to network technology X" like system at
my last job.  We were building a large networking switch with blades,
and the IO cards didn't have anywhere near the resources that the
control modules had (no persistent storage, small ram, etc).  We were
already doing userspace coredumps over NFS to the control cards.  It
would have been nice to swap as well.

