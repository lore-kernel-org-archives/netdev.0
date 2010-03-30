From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/2] netdev: ethtool RXHASH flag
Date: Tue, 30 Mar 2010 13:19:20 -0400
Message-ID: <4BB23298.6010601@garzik.org>
References: <20100328154448.701c89ee@nehalam> <20100329174727.4654e19c@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f199.google.com ([209.85.223.199]:43410 "EHLO
	mail-iw0-f199.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754975Ab0C3RZe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 13:25:34 -0400
Received: by iwn37 with SMTP id 37so475401iwn.15
        for <netdev@vger.kernel.org>; Tue, 30 Mar 2010 10:25:32 -0700 (PDT)
In-Reply-To: <20100329174727.4654e19c@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/29/2010 08:47 PM, Stephen Hemminger wrote:
> This adds ethtool and device feature flag to allow control
> of receive hashing offload.
>
> Signed-off-by: Stephen Hemminger<shemminger@vyatta.com>

Acked-by: Jeff Garzik <jgarzik@redhat.com>


