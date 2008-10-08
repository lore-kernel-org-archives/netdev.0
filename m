From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] Convert the UDP hash lock to RCU
Date: Wed, 08 Oct 2008 09:38:02 -0700 (PDT)
Message-ID: <20081008.093802.133779887.davem@davemloft.net>
References: <48EAF29D.8050203@cosmosbay.com>
	<20081007.112622.73930718.davem@davemloft.net>
	<48EC70BB.9010709@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: minyard@acm.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, shemminger@vyatta.com,
	paulmck@linux.vnet.ibm.com
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44444
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754352AbYJHQi1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 12:38:27 -0400
In-Reply-To: <48EC70BB.9010709@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 08 Oct 2008 10:35:07 +0200

> BTW is there any chance your results were obtained before October 2005 ?

No, the timestamp on the saved patch file I have is June 16, 2008 :-)
