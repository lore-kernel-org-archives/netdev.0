From: David Miller <davem@davemloft.net>
Subject: Re: We have FUSE, could we have NUSE ?
Date: Thu, 08 Mar 2007 13:52:26 -0800 (PST)
Message-ID: <20070308.135226.51854893.davem@davemloft.net>
References: <20070308105320.GB3883@mea-ext.zmailer.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: matti.aarnio@zmailer.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54502
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030691AbXCHVw0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Mar 2007 16:52:26 -0500
In-Reply-To: <20070308105320.GB3883@mea-ext.zmailer.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Matti Aarnio <matti.aarnio@zmailer.org>
Date: Thu, 8 Mar 2007 12:53:20 +0200

> We do have a support of file-system engine in userspace process.
> Could we have a socket interfaced network protocol engine in userspace ?

People can and have done this using the TUN/TAP device.
There is even an ad-hoc IPSEC implementation with X-AUTH
support implemented in user space using TUN/TAP.
