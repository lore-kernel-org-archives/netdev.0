From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 0/3] Introduce the Intel 82599 10 Gigabit
 Network Adapter family
Date: Sun, 01 Mar 2009 00:25:15 -0800 (PST)
Message-ID: <20090301.002515.46575653.davem@davemloft.net>
References: <20090228013916.22664.54781.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52688
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751289AbZCAIZd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2009 03:25:33 -0500
In-Reply-To: <20090228013916.22664.54781.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 27 Feb 2009 17:44:16 -0800

> The following series implements basic support for the new Intel 82599 10 Gigabit Network adapter.  Contained in this patchset is:
> 
> 	1) Hardware specific code to initialize the 82599 device
> 	2) Include Data Center Bridging support for 82599
> 	3) Add the current device ID's for 82599, including a fully pluggable 1G/10G SFP+ NIC, and a KX/KX4 mezzanine card

All applied.

I look forward to seeing you guys followup on the I2C usage
stuff Ben pointed out :-)
