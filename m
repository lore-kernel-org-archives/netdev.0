From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: fix WARN_ON when writing to bond_master sysfs
 file (v2)
Date: Tue, 05 Oct 2010 20:06:36 -0700 (PDT)
Message-ID: <20101005.200636.193714172.davem@davemloft.net>
References: <20101004202112.GA27897@hmsreliant.think-freely.org>
	<20101005133921.GA18071@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net,
	fubar@us.ibm.com, shemminger@vyatta.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49726
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755999Ab0JFDGP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 23:06:15 -0400
In-Reply-To: <20101005133921.GA18071@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Tue, 5 Oct 2010 09:39:21 -0400

> Ok, V2 of this patch, taking Stephens notes into account.  Switched to using
> __dev_get_by_name to avoid reference count inc/dec.

Applied, thanks Neil.
