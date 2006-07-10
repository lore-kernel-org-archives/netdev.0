From: Patrick McHardy <kaber@trash.net>
Subject: Re: [2.6 patch] netfilter: fix SYSCTL=n compile
Date: Mon, 10 Jul 2006 06:19:56 +0200
Message-ID: <44B1D56C.20903@trash.net>
References: <20060708202023.GE5020@stusta.de> <44B079FF.8060909@trash.net> <20060709233304.GX13938@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62088 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1161334AbWGJEVX
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jul 2006 00:21:23 -0400
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20060709233304.GX13938@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> This patch fixes the following compile errors with CONFIG_SYSCTL=n 
> introduced by commit 39a27a35c5c1b5be499a0576a35c45a011788bf8:

Thanks, applied.

