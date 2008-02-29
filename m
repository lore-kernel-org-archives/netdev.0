From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.26] [SCTP]: extend exported data in
 /proc/net/sctp/assoc
Date: Fri, 29 Feb 2008 11:41:09 -0800 (PST)
Message-ID: <20080229.114109.166834859.davem@davemloft.net>
References: <47C8227D.1050201@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48229
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751637AbYB2TlL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Feb 2008 14:41:11 -0500
In-Reply-To: <47C8227D.1050201@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Fri, 29 Feb 2008 10:19:25 -0500

> RFC 3873  specifies several MIB objects that can't be obtained by the
> current data set exported by /proc/sys/net/sctp/assoc.  This
> patch adds the missing pieces of data that allow us to compute all the
> objects in the sctpAssocTable object.
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied to net-2.6.26, thanks.
