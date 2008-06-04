From: David Miller <davem@davemloft.net>
Subject: commit header lines...
Date: Wed, 04 Jun 2008 15:56:18 -0700 (PDT)
Message-ID: <20080604.155618.242269951.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34585
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755260AbYFDW4T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2008 18:56:19 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 1C2CDC8C182
	for <netdev@vger.kernel.org>; Wed,  4 Jun 2008 15:56:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Some of you may have noticed, but I have been editing commit
header lines to be more in tune with what people use in the
rest of the kernel and what is facilitated best by the tools.

This basically means:

subsystem: Commit description

Where "subsystem" is in lower case and not surrounded by
"[" and "]" as we previously did in the past.

Please try to adhere to this in your patch submissions as
it saves work for me.

Thanks.
