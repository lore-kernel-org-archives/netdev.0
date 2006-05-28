From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] GRE: fixup gre_keymap_lookup() return type
Date: Mon, 29 May 2006 01:01:15 +0200
Message-ID: <447A2BBB.70703@trash.net>
References: <20060526190716.GA7266@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@lists.netfilter.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:3476 "EHLO stinky.trash.net")
	by vger.kernel.org with ESMTP id S1751031AbWE1XBa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 May 2006 19:01:30 -0400
To: Alexey Dobriyan <adobriyan@gmail.com>
In-Reply-To: <20060526190716.GA7266@martell.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Dobriyan wrote:
> GRE keys are 16-bit wide.

This looks harmless, so I've queued it for 2.6.18. Thanks.

