From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] gre_in_range: 16/32 bit fix
Date: Thu, 18 May 2006 16:47:12 +0200
Message-ID: <446C88F0.9010509@trash.net>
References: <20060518133852.GA13516@mipter.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:17322 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1751092AbWEROrO
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 May 2006 10:47:14 -0400
To: Alexey Dobriyan <adobriyan@gmail.com>
In-Reply-To: <20060518133852.GA13516@mipter.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Dobriyan wrote:
> GRE keys are 16 bit.


Thanks, I've combined both patches and added them to me tree, will
push to Dave soon.
