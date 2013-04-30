From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] sh_eth: use random MAC address if no valid one
 supplied
Date: Tue, 30 Apr 2013 15:37:29 -0400 (EDT)
Message-ID: <20130430.153729.859998606300915403.davem@davemloft.net>
References: <201304292349.43251.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nobuhiro.iwamatsu.yj@renesas.com,
	linux-sh@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <201304292349.43251.sergei.shtylyov@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Mon, 29 Apr 2013 23:49:42 +0400

> On Renesas R-Car based development boards, although a MAC address is printed on
> all the Ethernet port labels, U-Boot  doesn't write a valid MAC address  to the
> Ether MAHR/MALR registers (there's no storage provided for the Ether MAC address
> either), so we have to resort to using a random MAC address...
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied, thanks.
