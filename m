From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH NEXT 07/12] netxen: clean up frimware version checks
Date: Mon, 27 Jul 2009 10:38:11 -0700 (PDT)
Message-ID: <20090727.103811.16197779.davem@davemloft.net>
References: <1248674867-18821-1-git-send-email-dhananjay@netxen.com>
	<1248674867-18821-8-git-send-email-dhananjay@netxen.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dhananjay@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54893
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753465AbZG0RiE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2009 13:38:04 -0400
In-Reply-To: <1248674867-18821-8-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dhananjay Phadke <dhananjay@netxen.com>
Date: Sun, 26 Jul 2009 23:07:42 -0700

> NX2031 firmware version will never be > 4.0.0, so replace
> (adapter->fw_major < 4) checks with pci revision ID check.
> 
> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>

Applied.
