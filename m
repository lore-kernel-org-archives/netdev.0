From: David Miller <davem@davemloft.net>
Subject: Re: [ROSE/AX25] af_rose: rose_release() fix
Date: Tue, 01 Apr 2008 23:56:44 -0700 (PDT)
Message-ID: <20080401.235644.217541742.davem@davemloft.net>
References: <20080330115958.GA4975@ami.dom.local>
	<47F29CEE.10307@free.fr>
	<20080402064107.GA3975@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bpidoux@free.fr, ralf@linux-mips.org, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32901
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751840AbYDBG4n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2008 02:56:43 -0400
In-Reply-To: <20080402064107.GA3975@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Wed, 2 Apr 2008 06:41:07 +0000

> Here I resend the testing patch #5 from this thread: (the only change
> - it's against current netdev tree, so 1 line offset added).
>  }

Thanks so much for fixing this bug, applied to net-2.6
