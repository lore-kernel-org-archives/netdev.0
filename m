From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [ANNOUNCE] ixgbe: Data Center Bridging (DCB) support for ixgbe
Date: Fri, 02 May 2008 13:19:06 +0200
Message-ID: <87bq3peyxh.fsf@basil.nowhere.org>
References: <20080502004254.14392.7599.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out04.alice-dsl.net ([88.44.63.6]:40474 "EHLO
	smtp-out04.alice-dsl.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752284AbYEBLTJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2008 07:19:09 -0400
In-Reply-To: <20080502004254.14392.7599.stgit@localhost.localdomain> (PJ Waskiewicz's message of "Thu, 01 May 2008 17:42:54 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com> writes:
>
> The third patchset implements the netlink interface and hardware init code,
> and enables DCB support in the driver.

Probably the interface shouldn't be driver specific.

I would suggest you post a higher level description of the goals/implementation 
etc. of the interface.

-Andi
