From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2/2] veth: remove unused list
Date: Tue, 28 Oct 2008 22:08:57 -0700 (PDT)
Message-ID: <20081028.220857.65855513.davem@davemloft.net>
References: <20081028211142.359911603@fr.ibm.com>
	<20081028212120.658842697@fr.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xemul@openvz.org
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45215
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751332AbYJ2FJU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 01:09:20 -0400
In-Reply-To: <20081028212120.658842697@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <dlezcano@fr.ibm.com>
Date: Tue, 28 Oct 2008 22:11:44 +0100

> The veth network device is stored in a list in the netdev private.
> AFAICS, this list is never used so I removed this list from the code.
> 
> Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

Also applied, thanks for these cleanups.
