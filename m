From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: Re: [patch 2.6.31 08/10] wimax: Add netlink interface to get device state
Date: Thu, 28 May 2009 15:09:21 -0700
Message-ID: <200905281509.22233.inaky@linux.intel.com>
References: <4d58364611c66a20ea1e28223b8f638fd2e35981.1243472510.git.inaky@linux.intel.com> <200905280916.23022.inaky@linux.intel.com> <20090528.150600.133260652.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: wimax@linuxwimax.org, shemminger@vyatta.com,
	netdev@vger.kernel.org, paulius.zaleckas@teltonika.lt
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:14078 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751078AbZE1WJx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2009 18:09:53 -0400
In-Reply-To: <20090528.150600.133260652.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 28 May 2009, David Miller wrote:
> From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
> Date: Thu, 28 May 2009 09:16:21 -0700
>
> > Actually that's an extremely good point that I missed completely.
> > Thanks for catching it.
> >
> > David, I'll submit an extra commit for correcting that point.
>
> As I explained on IRC, it's better to repsin the patch set, putting
> the bug fix into patch #8 discussed here, rather than to add a
> follow-on fix for the bug.
>
> This way the tree is properly bisectable.

Thanks, I'll do so.

Sorry I missed you on IRC--had to run to a meeting.

-- 
Inaky
