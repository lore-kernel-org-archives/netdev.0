From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] add a sysctl to disable TCP simultaneous connection
 opening
Date: Wed, 08 Oct 2008 09:42:12 -0700 (PDT)
Message-ID: <20081008.094212.130684373.davem@davemloft.net>
References: <20081008081109.GA25342@1wt.eu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: w@1wt.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46017
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754097AbYJHQmg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 12:42:36 -0400
In-Reply-To: <20081008081109.GA25342@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I'm not really interested in applying this.

You can make the same argument for just about any queer corner case
aspect of TCP.

The world hasn't ended even though this patch hasn't applied since
2005 and that's a good argument to not apply "yet another random knob"
to the kernel.
