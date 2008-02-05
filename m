From: David Miller <davem@davemloft.net>
Subject: Re: [FIB] fix fib_proc compilation error
Date: Tue, 05 Feb 2008 02:54:45 -0800 (PST)
Message-ID: <20080205.025445.213093797.davem@davemloft.net>
References: <47A8285A.7040205@fr.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59155
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756344AbYBEKyR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 05:54:17 -0500
In-Reply-To: <47A8285A.7040205@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <dlezcano@fr.ibm.com>
Date: Tue, 05 Feb 2008 10:11:54 +0100

> Subject: fix fib_proc compilation error
> From: Daniel Lezcano <dlezcano@fr.ibm.com>
> 
> Fix fib_proc_[init|exit] definition when CONFIG_PROCFS=no
> 
> Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

Li Zefan already posted a fix for this which I've just
applied.
