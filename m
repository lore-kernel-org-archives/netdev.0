From: Amit Salecha <amit.salecha@qlogic.com>
Subject: RE: [PATCH net-next] netxen: make local function static.
Date: Tue, 19 Oct 2010 01:36:13 -0500
Message-ID: <99737F4847ED0A48AECC9F4A1974A4B80F871A7C62@MNEXMB2.qlogic.org>
References: <20101018204010.1dc01291@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>,
	Narender Kumar <narender.kumar@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexcashub1.qlogic.com ([198.70.193.61]:13165 "EHLO
	avexcashub1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933073Ab0JSGgS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Oct 2010 02:36:18 -0400
In-Reply-To: <20101018204010.1dc01291@nehalam>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Stephen Hemminger [mailto:shemminger@vyatta.com]
> Sent: Tuesday, October 19, 2010 9:10 AM
> To: Amit Salecha; David S. Miller; Narender Kumar; Rajesh Borundia
> Cc: netdev@vger.kernel.org
> Subject: [PATCH net-next] netxen: make local function static.
> 
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> ---
>  drivers/net/netxen/netxen_nic.h      |   18 +-----------------
>  drivers/net/netxen/netxen_nic_hw.c   |   29 +++++++++++---------------
> ---
>  drivers/net/netxen/netxen_nic_main.c |    6 ++++--
>  3 files changed, 16 insertions(+), 37 deletions(-)
> 

Thanks for this. I always run sparse tool before submitting patches, but I never got warning about this.

-Amit
