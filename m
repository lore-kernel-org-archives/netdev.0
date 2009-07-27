From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH NEXT 12/12] netxen: update version to 4.0.41
Date: Mon, 27 Jul 2009 10:54:03 -0700 (PDT)
Message-ID: <20090727.105403.202219074.davem@davemloft.net>
References: <1248674867-18821-1-git-send-email-dhananjay@netxen.com>
	<1248674867-18821-13-git-send-email-dhananjay@netxen.com>
	<20090727.103842.52201957.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dhananjay@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51924
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751106AbZG0Rx4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2009 13:53:56 -0400
In-Reply-To: <20090727.103842.52201957.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Ok, in order to make this build I'm going to have to insert
some parts of patch #6 which I rejected because that adds
ring size defaults/max/etc. defines which get used by later
patches.
