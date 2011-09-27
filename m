From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [PATCH] staging/octeon: Software should check the checksum of no
 tcp/udp packets
Date: Tue, 27 Sep 2011 04:01:28 +0200
Message-ID: <20110927020128.GA26048@linux-mips.org>
References: <1316999280-11999-1-git-send-email-rongqing.li@windriver.com>
 <4E80D794.3040701@cavium.com>
 <20110927005127.GB10447@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Daney <david.daney@cavium.com>, rongqing.li@windriver.com,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	linux-mips@linux-mips.org
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([78.24.191.182]:56071 "EHLO
	cvs.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751387Ab1I0CB1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2011 22:01:27 -0400
Received: from localhost.localdomain ([127.0.0.1]:56830 "EHLO linux-mips.org"
        rhost-flags-OK-OK-OK-FAIL) by eddie.linux-mips.org with ESMTP
        id S1492055Ab1I0CBZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 27 Sep 2011 04:01:25 +0200
Content-Disposition: inline
In-Reply-To: <20110927005127.GB10447@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 26, 2011 at 05:51:27PM -0700, Greg KH wrote:

> > This looks fine to me,
> > 
> > Acked-by: David Daney <david.daney@cavium.com>
> > 
> > I would let davem, Ralf and Greg KH fight over who gets to merge it.
> 
> I'll let Ralf take it, unless he wants me to.
> 
> Ralf?

Ok.  Yes, that seems the best solution.

  Ralf
