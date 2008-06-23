From: Josip Rodin <joy@entuzijast.net>
Subject: Re: bnx2_poll panicking kernel
Date: Mon, 23 Jun 2008 20:04:39 +0200
Message-ID: <20080623180439.GA18829@orion.carnet.hr>
References: <20080621113406.5f89ae8d.billfink@mindspring.com> <C27F8246C663564A84BB7AB343977242019B6FEC8E@IRVEXCHCCR01.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: 'Bill Fink' <billfink@mindspring.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev <netdev@vger.kernel.org>,
	"mirrors@debian.org" <mirrors@debian.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orion.CARNet.hr ([161.53.160.90]:46755 "EHLO orion.carnet.hr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752491AbYFWSEr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jun 2008 14:04:47 -0400
Content-Disposition: inline
In-Reply-To: <C27F8246C663564A84BB7AB343977242019B6FEC8E@IRVEXCHCCR01.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 21, 2008 at 09:11:05AM -0700, Michael Chan wrote:
> Bill Fink wrote:
> 
> >
> > Wouldn't the "modprobe -r bnx2" destroy the HTB info for that device?
> >
> >
> 
> I think it would.  Josip, you can do "tc -d class show dev eth0" to
> check.
> 

Oh, duh, yes, I'm a moron. It's back on now, sorry about that.

-- 
     2. That which causes joy or happiness.
