From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] net/sctp/auth.c: make 3 functions static
Date: Fri, 26 Oct 2007 04:21:49 -0700 (PDT)
Message-ID: <20071026.042149.216714577.davem@davemloft.net>
References: <20071024162428.GJ30533@stusta.de>
	<471FAABA.4080006@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bunk@kernel.org, sri@us.ibm.com,
	lksctp-developers@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33248
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751154AbXJZLVs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2007 07:21:48 -0400
In-Reply-To: <471FAABA.4080006@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Wed, 24 Oct 2007 16:27:38 -0400

> Adrian Bunk wrote:
> > This patch makes three needlessly global functions static.
> > 
> > Signed-off-by: Adrian Bunk <bunk@kernel.org>
> 
> ACK.  Thanks for catching these..

Applied, thanks everyone.
