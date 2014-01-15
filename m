From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH net-next 2/2] net: mvneta: make mvneta_txq_done() return void
Date: Wed, 15 Jan 2014 09:56:56 +0100
Message-ID: <20140115085656.GH4605@1wt.eu>
References: <cover.1389742334.git.arno@natisbad.org> <1e35971f3ee9f4d120bff5fe98179160998ea0fa.1389742334.git.arno@natisbad.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Arnaud Ebalard <arno@natisbad.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:55419 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751037AbaAOI5W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jan 2014 03:57:22 -0500
Content-Disposition: inline
In-Reply-To: <1e35971f3ee9f4d120bff5fe98179160998ea0fa.1389742334.git.arno@natisbad.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 15, 2014 at 12:46:52AM +0100, Arnaud Ebalard wrote:
> 
> The function return parameter is not used in mvneta_tx_done_gbe(),
> where the function is called. This patch makes the function return
> void.
> 
> Signed-off-by: Arnaud Ebalard <arno@natisbad.org>

Reviewed-by: Willy Tarreau <w@1wt.eu>
