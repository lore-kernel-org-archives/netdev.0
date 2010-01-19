From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] S2io: two branches the same in wait_for_cmd_complete()
Date: Tue, 19 Jan 2010 01:59:59 -0800 (PST)
Message-ID: <20100119.015959.104877543.davem@davemloft.net>
References: <4B53284C.1090405@gmail.com>
	<78C9135A3D2ECE4B8162EBDCE82CAD77061418BF@nekter>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roel.kluin@gmail.com, netdev@vger.kernel.org,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org
To: Ramkrishna.Vepa@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50762
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755701Ab0ASJ7t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2010 04:59:49 -0500
In-Reply-To: <78C9135A3D2ECE4B8162EBDCE82CAD77061418BF@nekter>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Date: Mon, 18 Jan 2010 02:20:06 -0500

> Thanks for catching this bug. The fix should be as follows -

This doesn't apply to net-2.6, and I'd need your signoff too.

Please fix this up and resubmit, thanks.
