From: David Miller <davem@davemloft.net>
Subject: Re: netfilter 02/03: xtables: add missing const qualifier to
 xt_tgchk_param
Date: Mon, 24 Nov 2008 16:06:27 -0800 (PST)
Message-ID: <20081124.160627.154677997.davem@davemloft.net>
References: <20081124134427.462.77824.sendpatchset@x2.localnet>
	<20081124134430.462.41146.sendpatchset@x2.localnet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20081124134430.462.41146.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 24 Nov 2008 14:44:38 +0100 (MET)

>     netfilter: xtables: add missing const qualifier to xt_tgchk_param
>     
>     When entryinfo was a standalone parameter to functions, it used to be
>     "const void *". Put the const back in.
>     
>     Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
>     Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied.
