From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/10] Tun fixes and netns migration
Date: Wed, 21 Jan 2009 16:03:27 -0800 (PST)
Message-ID: <20090121.160327.28061744.davem@davemloft.net>
References: <m1y6x5lmvy.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, maxk@qualcomm.com, xemul@openvz.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51063
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753016AbZAVADZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2009 19:03:25 -0500
In-Reply-To: <m1y6x5lmvy.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Tue, 20 Jan 2009 12:53:53 -0800

> Having a tun device that can be migrated between network namespaces 
> is interesting when setting up creative network topologies using
> network namespaces.
> 
> To get there requires some general clean and restructuring of the
> tun driver.

All applied to net-next-2.6, thanks Eric.
