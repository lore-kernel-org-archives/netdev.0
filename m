From: Aaron Brown <aaron.f.brown@intel.com>
Subject: Re: [PATCH net-next V2] intel: Remove unnecessary OOM messages
Date: Thu, 13 Feb 2014 16:03:36 -0800
Message-ID: <1392336216.1831.16.camel@localhost>
References: <1392168397.23721.2.camel@joe-AO722>
	 <1392168652.1868.1.camel@joe-AO722>
	 <20140213.174723.1145739288167542959.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, jeffrey.t.kirsher@intel.com,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:20407 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751861AbaBNADy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Feb 2014 19:03:54 -0500
In-Reply-To: <20140213.174723.1145739288167542959.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-02-13 at 17:47 -0500, David Miller wrote:
> From: Joe Perches <joe@perches.com>
> Date: Tue, 11 Feb 2014 17:30:52 -0800
> 
> > Don't emit these as there's a generic OOM with a dump_stack()
> > on allocation failures.
> > 
> > Signed-off-by: Joe Perches <joe@perches.com>
> > ---
> > 
> > With patch attached this time...
> 
> I expect the Intel folks to pick this up.

Yes indeed, I have already pulled it into our test queue.  Thanks...
