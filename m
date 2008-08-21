From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/8] sysfs namespace support
Date: Wed, 20 Aug 2008 23:37:22 -0700 (PDT)
Message-ID: <20080820.233722.216964061.davem@davemloft.net>
References: <m1vdzmh2jr.fsf_-_@frodo.ebiederm.org>
	<20080820021754.GA25182@kroah.com>
	<m1od3m282j.fsf_-_@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greg@kroah.com, gregkh@suse.de, akpm@linux-foundation.org,
	htejun@gmail.com, dlezcano@fr.ibm.com,
	linux-kernel@vger.kernel.org, viro@ftp.linux.org.uk,
	containers@lists.osdl.org, benjamin.thery@bull.net,
	netdev@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55942
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753400AbYHUGhX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 02:37:23 -0400
In-Reply-To: <m1od3m282j.fsf_-_@frodo.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Wed, 20 Aug 2008 23:31:00 -0700

> 
> Greg the first 4 patches are the rest of the infrastructure.
> Everything rebased quite nicely.  All of the conflicts appear
> to have been false positives.
> 
> With the addition of sysfs_rename_link sysfs_create_link_nowarn
> is never called so we can remove it.
> 
> I'm not really certain whose tree the last netns or the user
> namespace changes should live in, but I am continuing to
> have those patches in this patchset for completeness.

You can send it all through Greg or whoever, don't feel obligated to
push it through me since it depends upon the earlier bits in this
series.
