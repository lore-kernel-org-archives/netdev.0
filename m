From: David Miller <davem@davemloft.net>
Subject: Re: [patch 11/11][NETNS][IPV6] rt6_stats - make the stats per
 network namespace
Date: Tue, 04 Mar 2008 11:54:25 -0800 (PST)
Message-ID: <20080304.115425.165558612.davem@davemloft.net>
References: <20080302094243.621444844@mai.toulouse-stg.fr.ibm.com>
	<20080303.233430.199177100.davem@davemloft.net>
	<47CD63EE.8090204@bull.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlezcano@fr.ibm.com, netdev@vger.kernel.org
To: benjamin.thery@bull.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58618
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1762585AbYCDTye (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 14:54:34 -0500
In-Reply-To: <47CD63EE.8090204@bull.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Thery <benjamin.thery@bull.net>
Date: Tue, 04 Mar 2008 15:59:58 +0100

> I can't see the patches in net-2.6.26 tree. Have you been forced
> to revert them because they conflict with Yoshifuji patchset?

No, I took care of all of the conflicts by hand.

> or am I too impatient? :)

I forgot to push, simply :-)

It should be there now, sorry about that.
