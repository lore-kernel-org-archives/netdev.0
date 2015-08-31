From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [PATCH iproute2 v3] add 'vti'/'vti6' tunnel modes to ip-tunnel
 manual page
Date: Mon, 31 Aug 2015 16:29:20 -0700
Message-ID: <20150831162920.149b9fc8@urahara>
References: <d1bff31765e84932b3b327fdeddc4c71@HQ1WP-EXMB11.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Konstantin Shemyak <konstantin@shemyak.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:42211 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752476AbbHaX3M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2015 19:29:12 -0400
In-Reply-To: <d1bff31765e84932b3b327fdeddc4c71@HQ1WP-EXMB11.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 29 Aug 2015 18:36:32 +0000
Konstantin Shemyak <konstantin@shemyak.com> wrote:

> * "vti" and "vti6" tunnel modes added to ip-tunnel.8 manual page
> * Added "hoplimit" terminology for IPv6
> * Corrected usage line
> * Minor language fix
> ---
>  man/man8/ip-tunnel.8 | 24 ++++++++++++------------
>  1 file changed, 12 insertions(+), 12 deletions(-)

Applied, thanks
