From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/41]bnx2x: enhancements and clean up for net-next
Date: Sun, 15 Feb 2009 23:36:09 -0800 (PST)
Message-ID: <20090215.233609.86653297.davem@davemloft.net>
References: <1234463763.1863.131.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yanivr@broadcom.com,
	harvey.harrison@gmail.com
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40363
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751964AbZBPHgZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Feb 2009 02:36:25 -0500
In-Reply-To: <1234463763.1863.131.camel@lb-tlvb-eliezer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Thu, 12 Feb 2009 20:36:03 +0200

> Finally, an enhancement patch for the bnx2x. Due to many reasons (among
> which FW stability and chasing some bugs) it took a while to stabilize
> and the longer it took the longer the list got. So unfortunately, this
> is a long list - hopefully for the last time. I realize that sending a
> too many patches together is bad practice and I will do my best to avoid
> it in the future.

You're lucky I'm in a really good mood today :-)

> The first patch is a new FW patch. It is way too big for the mailing
> list, but I'm hoping you will get it directly to your mailbox. This
> patch has very little review value since it is simply the new FW blob,
> FW header file renames and the mandatory driver renames to accommodate
> it.
> 
> Please consider applying to net-next.

Ok, everything is applied to net-next-2.6 and pushed out to kernel.org

Please followup with patches for Ben Hutchings's feedback, as you
promised you would.

Thank you.
