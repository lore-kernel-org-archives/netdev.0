From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] [TRIVIAL] prism54/islpci_eth.c: dev_kfree_skb in irq
 context
Date: Tue, 03 Jan 2006 14:11:44 +0100
Message-ID: <43BA7810.6010308@trash.net>
References: <6.1.1.1.2.20060103105620.02c523e0@192.168.6.12> <6ec4247d0601030419w377fd396x@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Roger While <simrw@sim-basis.de>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751398AbWACNMU@vger.kernel.org>
To: Graham Gower <graham.gower@gmail.com>
In-Reply-To: <6ec4247d0601030419w377fd396x@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Graham Gower wrote:
> My logs were starting to fill with messages exatcly like that mentioned here:
> http://patchwork.netfilter.org/netfilter-devel/patch.pl?id=2840
> 
> In any event, the patch at the end of that link was never applied (it doesn't
> fix the other call to dev_kfree_skb). After applying my patch, I've not had any
> more messages in the logs.

The patch has been applied to 2.6.15-rc. Only the first hunk of your
patch is still required, but it doesn't apply anymore. Can you send
a new patch against 2.6.15 please?
