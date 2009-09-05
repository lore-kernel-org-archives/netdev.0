From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlink: silence compiler warning
Date: Sat, 05 Sep 2009 01:13:34 -0700 (PDT)
Message-ID: <20090905.011334.178722186.davem@davemloft.net>
References: <4AA1C086.5000607@hp.com>
	<20090904.203318.112406812.davem@davemloft.net>
	<4AA218C8.4050800@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brian.haley@hp.com, marcel@holtmann.org, netdev@vger.kernel.org,
	sfr@canb.auug.org.au
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38033
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751088AbZIEINT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Sep 2009 04:13:19 -0400
In-Reply-To: <4AA218C8.4050800@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Sat, 05 Sep 2009 09:52:40 +0200

> http://permalink.gmane.org/gmane.linux.kernel.next/8786

Right, and that was my thinking.  So setting it to zero to
begin with is the right thing to do.
