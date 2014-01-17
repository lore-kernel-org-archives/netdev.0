From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v7 net-next 1/4] sh_eth: Use bool as return type of sh_eth_is_gether()
Date: Fri, 17 Jan 2014 23:25:49 +0300
Message-ID: <52D991CD.7050301@cogentembedded.com>
References: <1389918150-19058-1-git-send-email-horms+renesas@verge.net.au> <1389918150-19058-2-git-send-email-horms+renesas@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org,
	Magnus Damm <magnus.damm@gmail.com>
To: Simon Horman <horms+renesas@verge.net.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:65042 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753644AbaAQTZo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 14:25:44 -0500
Received: by mail-la0-f53.google.com with SMTP id e16so3943525lan.40
        for <netdev@vger.kernel.org>; Fri, 17 Jan 2014 11:25:42 -0800 (PST)
In-Reply-To: <1389918150-19058-2-git-send-email-horms+renesas@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 01/17/2014 03:22 AM, Simon Horman wrote:

> Return a boolean from sh_eth_is_gether() and refactor it as a one-liner.

> Signed-off-by: Simon Horman <horms+renesas@verge.net.au>

Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

WBR, Sergei
