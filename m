From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH net-next 1/2] net: mvneta: mvneta_tx_done_gbe() cleanups
Date: Wed, 15 Jan 2014 09:56:28 +0100
Message-ID: <20140115085628.GG4605@1wt.eu>
References: <cover.1389742334.git.arno@natisbad.org> <5880b38afc5884f5ed57c26824cc37666bd60b99.1389742334.git.arno@natisbad.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Arnaud Ebalard <arno@natisbad.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:55414 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751037AbaAOI45 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jan 2014 03:56:57 -0500
Content-Disposition: inline
In-Reply-To: <5880b38afc5884f5ed57c26824cc37666bd60b99.1389742334.git.arno@natisbad.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 15, 2014 at 12:45:49AM +0100, Arnaud Ebalard wrote:
> 
> mvneta_tx_done_gbe() return value and third parameter are no more
> used. This patch changes the function prototype and removes a useless
> variable where the function is called.
> 
> Signed-off-by: Arnaud Ebalard <arno@natisbad.org>

Reviewed-by: Willy Tarreau <w@1wt.eu>

Willy
