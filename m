From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH] powerpc/83xx: Enable FIXED_PHY in mpc834x_itx and mpc83xx defconfigs
Date: Thu, 4 Dec 2008 18:48:36 -0600
Message-ID: <D3ADB80B-5A8C-4D10-8FB9-CB29392E68B5@kernel.crashing.org>
References: <ed82fe3e0812040915i696e99bep75a37b0e38154415@mail.gmail.com> <20081204175231.GA28554@oksana.dev.rtsoft.ru>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: Timur Tabi <timur@freescale.com>, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, afleming@freescale.com
To: avorontsov@ru.mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:39360 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753019AbYLEAu7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Dec 2008 19:50:59 -0500
In-Reply-To: <20081204175231.GA28554@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Dec 4, 2008, at 11:52 AM, Anton Vorontsov wrote:

> This is needed so that Vitesse 7385 5-port switch could work on
> MPC8349E-mITX boards.
>
> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
> ---

applied to merge.

Guys, can you put a [for 2.6.28] or something if a patch is intended  
for .28.. this way I hopefully pay a bit more attention.

- k
