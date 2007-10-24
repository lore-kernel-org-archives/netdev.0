From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [2.6 patch] net/sctp/auth.c: make 3 functions static
Date: Wed, 24 Oct 2007 16:27:38 -0400
Message-ID: <471FAABA.4080006@hp.com>
References: <20071024162428.GJ30533@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: sri@us.ibm.com, lksctp-developers@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:46934 "EHLO atlrel9.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754051AbXJXU1p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Oct 2007 16:27:45 -0400
In-Reply-To: <20071024162428.GJ30533@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> This patch makes three needlessly global functions static.
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>

ACK.  Thanks for catching these..

-vlad
