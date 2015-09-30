From: Bastian Stender <bst@pengutronix.de>
Subject: Re: [PATCH] net ipv4: use preferred log methods
Date: Wed, 30 Sep 2015 13:07:53 +0200
Message-ID: <560BC289.40002@pengutronix.de>
References: <20150928.222409.1641594777817922710.davem@davemloft.net> <1443604843-22166-1-git-send-email-bst@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, trivial@kernel.org, kernel@pengutronix.de
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:60143 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754317AbbI3LH4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 07:07:56 -0400
In-Reply-To: <1443604843-22166-1-git-send-email-bst@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 09/30/2015 11:20 AM, Bastian Stender wrote:
> Replace printk calls with preferred unconditional log method calls to keep
> kernel messages clean.
>
> Signed-off-by: Bastian Stender <bst@pengutronix.de>
> ---
>   net/ipv4/ipconfig.c                            | 53 +++++++++-----------------
>   net/ipv4/netfilter/arp_tables.c                | 17 +--------
>   net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |  2 +-
>   net/ipv4/netfilter/nf_nat_snmp_basic.c         | 31 ++++++++-------
>   4 files changed, 36 insertions(+), 67 deletions(-)

Please ignore my previous patch. I'll test it again and resubmit it.

Thanks for your patience.

Regards,
Bastian Stender
