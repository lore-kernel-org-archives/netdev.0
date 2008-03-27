From: David Miller <davem@davemloft.net>
Subject: Re: [patch for 2.6.25? 3/3] skge napi->poll() locking bug
Date: Thu, 27 Mar 2008 14:57:00 -0700 (PDT)
Message-ID: <20080327.145700.126974082.davem@davemloft.net>
References: <200803270745.m2R7jEUA024166@imap1.linux-foundation.org>
	<47EB91B1.8000307@garzik.org>
	<20080327101142.4ad339b9.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, mitov@issp.bas.bg
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47052
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756227AbYC0V5A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 17:57:00 -0400
In-Reply-To: <20080327101142.4ad339b9.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Thu, 27 Mar 2008 10:11:42 -0700

> On Thu, 27 Mar 2008 08:23:13 -0400 Jeff Garzik <jeff@garzik.org> wrote:
> 
> > davem already has this
> 
> In which I discover that net-2.6.26 doesn't include net-2.6?

They get merged into eachother, as needed.
