From: Eli Cohen <eli@mellanox.com>
Subject: Re: [PATCH] Add support for configuring Infiniband GUIDs
Date: Fri, 13 May 2016 22:52:25 +0300
Message-ID: <20160513195225.GC135142@x-vnc01.mtx.labs.mlnx>
References: <1462549405-16003-1-git-send-email-eli@mellanox.com>
 <20160506115341.5b8d4587@xeon-e3>
 <DB5PR05MB1848F2481D0767935CA14399C5700@DB5PR05MB1848.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "shemminger@osdl.org" <shemminger@osdl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Eli Cohen (eli@dev.mellanox.co.il)" <eli@dev.mellanox.co.il>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:43318 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932211AbcEMTw5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 May 2016 15:52:57 -0400
Content-Disposition: inline
In-Reply-To: <DB5PR05MB1848F2481D0767935CA14399C5700@DB5PR05MB1848.eurprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

can you please comment on this or are you going to apply this?

On Mon, May 09, 2016 at 03:52:02PM +0000, Eli Cohen wrote:
> Hi Stephen,
> 
> ibstat is usually used with MLNX_OFED distributions and I don't think it is a part of libibverbs.
> Moreover, in a previous patch I sent https://patchwork.ozlabs.org/patch/596492/ I documented in the change log the same format I mention in this patch. So if I change the format here we will have the changelog in the kernel tree invalid.
> 
> How do you think this should be addressed?
> 
