From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/4] network dev read_mostly
Date: Mon, 12 Mar 2007 14:34:01 -0700 (PDT)
Message-ID: <20070312.143401.18577610.davem@davemloft.net>
References: <20070312210817.485320783@linux-foundation.org>
	<20070312210907.509184287@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59667
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932173AbXCLVeC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2007 17:34:02 -0400
In-Reply-To: <20070312210907.509184287@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Mon, 12 Mar 2007 14:08:18 -0700

> For Eric, mark packet type and network device watermarks
> as read mostly.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

Applied.
