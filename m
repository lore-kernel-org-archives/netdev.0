From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [2.6 patch] remove sctp_assoc_proc_exit()
Date: Tue, 22 Jul 2008 20:21:50 -0400
Message-ID: <4886799E.70505@hp.com>
References: <20080722172057.GU14846@cs181140183.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>, sri@us.ibm.com,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:48650 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752857AbYGWAVx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2008 20:21:53 -0400
In-Reply-To: <20080722172057.GU14846@cs181140183.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adrian Bunk wrote:
> Commit 20c2c1fd6c842caf70dcb1d94b9d58861949fd3d
> (sctp: add sctp/remaddr table to complete RFC remote address table OID)
> added an unused sctp_assoc_proc_exit() function that seems to have been 
> unintentionally created when copying the assocs code.
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>
> 
>


Acked-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Thanks Adrian
-vlad
