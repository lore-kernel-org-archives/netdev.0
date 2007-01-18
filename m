From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: Please pull 'upstream' branch of wireless-2.6
Date: Thu, 18 Jan 2007 07:16:44 -0500
Message-ID: <20070118121644.GJ11056@tuxdriver.com>
References: <20070103024117.GB5661@tuxdriver.com> <20070103024247.GC5661@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4355 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932281AbXARM4O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Jan 2007 07:56:14 -0500
To: jeff@garzik.org
Content-Disposition: inline
In-Reply-To: <20070103024247.GC5661@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 02, 2007 at 09:42:47PM -0500, John W. Linville wrote:
> The following changes since commit fe5f8e2a1c5c040209c598a28e19c55f30e1040d:
>   Zhu Yi (1):
>         ipw2100: Fix dropping fragmented small packet problem
> 
> are found in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream
> 
> Daniel Drake (5):
>       zd1211rw: Generic HMAC initialization
>       zd1211rw: 2 new ZD1211B device ID's
>       zd1211rw: Consistency for address space constants
>       zd1211rw: Remove addressing abstraction
>       zd1211rw: Add ID for Linksys WUSBF54G
> 
> John W. Linville (1):
>       softmac: avoid assert in ieee80211softmac_wx_get_rate
> 
> Kai Engert (1):
>       prism54: add ethtool -i interface
> 
> Larry Finger (1):
>       bcm43xx: Interrogate hardware-enable switch and update LEDs
> 
> Michael Buesch (1):
>       Update Prism54 MAINTAINERS entry

Jeff, it looks like you didn't pull this one yet.  I'm going to rebase
my upstream branch on top of my additions to my upstream-fixes branch.
So, just ignore this request and wait for the next round of pull
requests.

The next round is ready to go, except I can't login to
master.kernel.org today.  As soon as that is resolved, I'll push and
send the pull requests.

Thanks,

John

P.S.  If you haven't pulled due to some objection, please send me a
note to let me know why.
-- 
John W. Linville
linville@tuxdriver.com
