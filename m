From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 00/15][pull-request] Intel Wired LAN Driver
 Update
Date: Sat, 25 Dec 2010 19:26:26 -0800 (PST)
Message-ID: <20101225.192626.226792756.davem@davemloft.net>
References: <1293257174-15498-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50422
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751484Ab0LZDZ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Dec 2010 22:25:57 -0500
In-Reply-To: <1293257174-15498-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: jeffrey.t.kirsher@intel.com
Date: Fri, 24 Dec 2010 22:05:59 -0800

> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> 
> The following series addresses the more significant issues reported by
> checkpatch when run against the e1000e driver files.  The less serious
> whitespace and lines over 80 characters issues are not addressed.  In
> addition, added support for anti-spoofing and X540 SR-IOV.
> 
> The remaining warnings for msleep < 20ms will be addressed in a follow-on
> patch after a thorough investigation into the timings tolerated by the
> hardware.
> 
> The following changes since commit e1928c86c4829703b800c81cc9edc939b5634e6f:
> 
>  cnic: Add FCoE support on 57712
> 
> are available in the git repository at:
> 
>  master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net-next-2.6.git master

Pulled, thanks Jeff.
