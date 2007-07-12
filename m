From: David Miller <davem@davemloft.net>
Subject: Re: TCP stalls in current git, possibly splice related
Date: Thu, 12 Jul 2007 13:52:54 -0700 (PDT)
Message-ID: <20070712.135254.112289065.davem@davemloft.net>
References: <Line.LNX.4.64.0707121608100.10773@d.namei>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jens.axboe@oracle.com, netdev@vger.kernel.org
To: jmorris@namei.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49852
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759578AbXGLUwz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2007 16:52:55 -0400
In-Reply-To: <Line.LNX.4.64.0707121608100.10773@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: James Morris <jmorris@namei.org>
Date: Thu, 12 Jul 2007 16:12:25 -0400 (EDT)

> I'm seeing TCP connection stalls with current git, and a bisect found the 
> following as a possible cause:

To add to this James is seeing this with distcc I believe.
