From: Jeff Garzik <jeff@garzik.org>
Subject: Re: How to grab a block of binary data w/out using ioctls?
Date: Tue, 24 Oct 2006 01:00:14 -0400
Message-ID: <20061024050014.GC12506@havoc.gtf.org>
References: <453D61E8.8020400@candelatech.com> <20061023215448.f4f6c95a.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Greear <greearb@candelatech.com>,
	NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:33977 "EHLO havoc.gtf.org")
	by vger.kernel.org with ESMTP id S1752033AbWJXFAP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2006 01:00:15 -0400
To: Randy Dunlap <randy.dunlap@oracle.com>
Content-Disposition: inline
In-Reply-To: <20061023215448.f4f6c95a.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 23, 2006 at 09:54:48PM -0700, Randy Dunlap wrote:
> Similarly, sysfs is desirable in some circumstances, but
> not for blocks of binary data.

sysfs specifically has APIs for binary data...

	Jeff



