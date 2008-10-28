From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/6] net: replace all current users of NIP6_SEQFMT with
 %#p6
Date: Tue, 28 Oct 2008 16:06:12 -0700 (PDT)
Message-ID: <20081028.160612.90419792.davem@davemloft.net>
References: <1225223616.11483.40.camel@brick>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joe@perches.com
To: harvey.harrison@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38503
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752567AbYJ1XGe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 19:06:34 -0400
In-Reply-To: <1225223616.11483.40.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harvey Harrison <harvey.harrison@gmail.com>
Date: Tue, 28 Oct 2008 12:53:36 -0700

> The define in kernel.h can be done away with at a later time.
> 
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>

Applied.

Feel free to send me a removal patch now, the chance that there is
an out of tree user is basically zero and even if it did exist
we don't care.
