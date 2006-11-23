From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.19-rc6 : Spontaneous reboots, stack overflows - seems to
 implicate xfs, scsi, networking, SMP
Date: Thu, 23 Nov 2006 11:42:47 -0800 (PST)
Message-ID: <20061123.114247.129061695.davem@davemloft.net>
References: <20061123011809.GY37654165@melbourne.sgi.com>
	<20061122.201013.112290046.davem@davemloft.net>
	<20061123070837.GV11034@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesper.juhl@gmail.com, chatz@melbourne.sgi.com,
	linux-kernel@vger.kernel.org, xfs@oss.sgi.com,
	xfs-masters@oss.sgi.com, netdev@vger.kernel.org,
	linux-scsi@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:15307
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S933271AbWKWTmm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Nov 2006 14:42:42 -0500
To: dgc@sgi.com
In-Reply-To: <20061123070837.GV11034@melbourne.sgi.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Chinner <dgc@sgi.com>
Date: Thu, 23 Nov 2006 18:08:37 +1100

> Sure, we're trying to but it takes time.  However, if it's such a
> problem for you now and you want this process sped up, then _please,
> please, please_ submit patches to help fix the problem.....

As noted in other replies, such patch submissions have been rejected
by the XFS maintainers in the past.  So don't give the false
impression that people aren't trying to submit patches to fix this
problem.

The problem is the XFS maintainers rejecting the layering removal
patches.

