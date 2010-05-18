From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] cnic: Convert cnic_local_flags to atomic ops.
Date: Tue, 18 May 2010 15:17:14 -0700 (PDT)
Message-ID: <20100518.151714.233425751.davem@davemloft.net>
References: <1274218373-16324-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35296
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755950Ab0ERWRF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 18:17:05 -0400
In-Reply-To: <1274218373-16324-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Tue, 18 May 2010 14:32:52 -0700

> It is easier to expand the flags for other purposes because it does
> not require a spin_lock.  The next bug fix patch needs a flag in
> cnic_local_flags.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
