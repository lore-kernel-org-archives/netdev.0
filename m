From: Dimitris Michailidis <dm@chelsio.com>
Subject: Re: [PATCH 2/3] cxgb4: function namespace cleanup (v3)
Date: Mon, 18 Oct 2010 16:16:24 -0700
Message-ID: <4CBCD548.3030005@chelsio.com>
References: <20101015212310.47a74d86@nehalam>	<4CB9434D.1060702@chelsio.com>	<4CBA6DC8.4010104@opengridcomputing.com>	<20101018.073145.189710492.davem@davemloft.net> <20101018083918.3777a278@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, swise@opengridcomputing.com,
	divy@chelsio.com, leedom@chelsio.com, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:27082 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755064Ab0JRXQc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Oct 2010 19:16:32 -0400
In-Reply-To: <20101018083918.3777a278@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> Make functions only used in one file local.
> Remove lots of dead code, relating to unsupported functions
> in mainline driver like RSS, IPv6, and TCP offload.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Acked-by: Dimitris Michailidis <dm@chelsio.com>

Thanks much.
