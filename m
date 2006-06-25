From: Martin Michlmayr <tbm@cyrius.com>
Subject: Re: [patch 1/2] tulip: fix for 64-bit mips
Date: Sun, 25 Jun 2006 10:31:08 +0100
Message-ID: <20060625093108.GA29132@unjust.cyrius.com>
References: <200606250845.k5P8j1Tt020829@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: val_henson@linux.intel.com, jeff@garzik.org,
	netdev@vger.kernel.org, maillist@jg555.com,
	grundler@parisc-linux.org, pdh@colonel-panic.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sorrow.cyrius.com ([65.19.161.204]:40456 "EHLO
	sorrow.cyrius.com") by vger.kernel.org with ESMTP id S932181AbWFYJbV
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Jun 2006 05:31:21 -0400
To: akpm@osdl.org
Content-Disposition: inline
In-Reply-To: <200606250845.k5P8j1Tt020829@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* akpm@osdl.org <akpm@osdl.org> [2006-06-25 01:45]:
> Cc: Valerie Henson <val_henson@linux.intel.com>
> 
> [akpm: this is a previously-nacked patch, but the problem is real]

And, for the record, Jeff's suggestion as to how to rework the patch:

| Answer hasn't changed since this was last discussed:  sleep, rather than
| delay for an extra-long time.  That's the only hurdle for the tulip
| patches you keep resending.

| Francois Romieu even had an untested patch that attempted this,
| somewhere.

Now we just need someone to complete this work...
-- 
Martin Michlmayr
tbm@cyrius.com
