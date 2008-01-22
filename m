From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bluetooth : move children of connection device to NULL
 before connection down
Date: Mon, 21 Jan 2008 22:26:47 -0800 (PST)
Message-ID: <20080121.222647.34948119.davem@davemloft.net>
References: <20080121045401.GB4162@darkstar.te-china.tietoenator.com>
	<20080121.031417.171098597.davem@davemloft.net>
	<1200982696.7978.148.camel@aeonflux>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hidave.darkstar@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, bluez-devel@lists.sourceforge.net,
	cornelia.huck@de.ibm.com, gombasg@sztaki.hu, htejun@gmail.com,
	viro@zeniv.linux.org.uk, kay.sievers@vrfy.org, greg@kroah.com
To: marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44838
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753249AbYAVG0l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2008 01:26:41 -0500
In-Reply-To: <1200982696.7978.148.camel@aeonflux>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcel Holtmann <marcel@holtmann.org>
Date: Tue, 22 Jan 2008 07:18:16 +0100

> Right now I can't think of any side effects by this patch. Actually I
> only see an improvement with this patch. So please take it directly and
> starting with next week, I gonna make sure that they are handled again
> properly by me.

Excellent, I'll do that.

Thanks for the feedback.
