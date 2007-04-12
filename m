From: CaT <cat@zip.com.au>
Subject: Re: intermittant petabyte usage reported with broadcom nic
Date: Fri, 13 Apr 2007 09:25:58 +1000
Message-ID: <20070412232558.GV8345@zip.com.au>
References: <20070402014319.GA8345@zip.com.au> <20070402001300.3b66007d.akpm@linux-foundation.org> <20070412225249.GU8345@zip.com.au> <20070412161305.09cb28b8.akpm@linux-foundation.org> <adaodltdvwf.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Michael Chan <mchan@broadcom.com>
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nessie.weebeastie.net ([220.233.7.36]:4037 "EHLO
	bunyip.lochness.weebeastie.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753491AbXDLXY0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2007 19:24:26 -0400
Content-Disposition: inline
In-Reply-To: <adaodltdvwf.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 12, 2007 at 04:18:24PM -0700, Roland Dreier wrote:
> > > Apr 11 22:14:02 '  eth0:220898233988841368 66750274    0    0    0     0          0  86458738 52386430545 101089219 199313    0    0     0  199313          0 '
> 
> > > Apr 11 22:15:02 '  eth0:17227454818 81381144    0    0    0     0          0         0 33091307388 86658381    0    0    0     0       0          0 '
> 
> > But in fact I think you're saying that the numbers go bad, and then stay bad.
> 
> Doesn't look like it -- one minute after the first hiccup the eth0 #s
> look reasonable again.

Yeah. Sorry for not making it clear. I included good values on either
side of the bad one.

-- 
    "To the extent that we overreact, we proffer the terrorists the
    greatest tribute."
    	- High Court Judge Michael Kirby
