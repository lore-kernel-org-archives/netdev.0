From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-2.6.25 2/2][NETNS] net: Add a helper function
 neigh_param_default_alloc
Date: Mon, 24 Dec 2007 15:56:59 -0800 (PST)
Message-ID: <20071224.155659.102282612.davem@davemloft.net>
References: <20071221130223.348101205@ICON-9-164-138-215.megacenter.de.ibm.com>
	<20071221131606.284066116@ICON-9-164-138-215.megacenter.de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, den@openvz.org, benjamin.thery@bull.net
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46926
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751897AbXLXX5A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Dec 2007 18:57:00 -0500
In-Reply-To: <20071221131606.284066116@ICON-9-164-138-215.megacenter.de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric.W.Biederman" <ebiederm@xmission.com>"@fr.ibm.com
Date: Fri, 21 Dec 2007 14:02:25 +0100

> In the presence of multiple network namespaces the logic needed
> to allocate the a default parameter table is just barely non-trivial.
> So add a function to automate it to make everyone's life easier.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
> Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

Please submit this patch with the patch set that starts
to use the new interface.

There is no need to add it now, thanks.
