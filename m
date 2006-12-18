From: David Miller <davem@davemloft.net>
Subject: Re: Deadlock in MD5 Signature support
Date: Sun, 17 Dec 2006 17:13:37 -0800 (PST)
Message-ID: <20061217.171337.110116170.davem@davemloft.net>
References: <53701.81.105.127.245.1166379186.squirrel@www.solinno.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39569
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750843AbWLRBNg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Dec 2006 20:13:36 -0500
To: leigh@solinno.co.uk
In-Reply-To: <53701.81.105.127.245.1166379186.squirrel@www.solinno.co.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Leigh Brown" <leigh@solinno.co.uk>
Date: Sun, 17 Dec 2006 18:13:06 -0000 (GMT)

> It was all going so well, and then it deadlocked.  What can be done
> about this?

Thanks for the trace, I'll take a look Leigh.
