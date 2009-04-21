From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/8] tg3: Limit CLKREQ fix to A[01] of 57780 asic rev
Date: Tue, 21 Apr 2009 01:42:20 -0700 (PDT)
Message-ID: <20090421.014220.118341184.davem@davemloft.net>
References: <1240247959.7024@xw6200>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com, benli@broadcom.com,
	andy@greyhouse.net
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54737
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753170AbZDUIm3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 04:42:29 -0400
In-Reply-To: <1240247959.7024@xw6200>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Mon, 20 Apr 2009 09:58:27 -0700

> This patch restricts the CLKREQ bugfix to the A0 and A1 revisions
> of 57780 ASIC rev chips.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
