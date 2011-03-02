From: "Alex G." <mr.nuke.me@gmail.com>
Subject: Re: [PATCH] via-rhine: do not abort due to invalid MAC address
Date: Wed, 02 Mar 2011 21:49:07 +0200
Message-ID: <4D6E9F33.2030001@gmail.com>
References: <20110302163233.GA14491@core.hellgate.ch> <201103021901.39849.florian@openwrt.org> <4D6E883C.2000800@gmail.com> <20110302.113610.71137356.davem@davemloft.net> <20110302195205.GA15190@core.hellgate.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, florian@openwrt.org,
	netdev@vger.kernel.org
To: Roger Luethi <rl@hellgate.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:34192 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757404Ab1CBTxl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 14:53:41 -0500
Received: by bwz15 with SMTP id 15so501930bwz.19
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2011 11:53:40 -0800 (PST)
In-Reply-To: <20110302195205.GA15190@core.hellgate.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/02/2011 09:52 PM, Roger Luethi wrote:
> On Wed, 02 Mar 2011 11:36:10 -0800, David Miller wrote:
>> There is no reason to choose a different strategy for this driver.
> 
> Fair enough. I did not know other drivers had already dealt with the same
> problem. My bad. Alex, can you redo the patch accordingly?

Yes, no problem.

Alex
