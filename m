From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] soreuseport: change consume_skb to kfree_skb
 in error case
Date: Tue, 05 Jan 2016 17:39:48 +0100
Message-ID: <568BF1D4.8000906@iogearbox.net>
References: <1452009433-22171-1-git-send-email-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Craig Gallek <kraigatgoog@gmail.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:43407 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751487AbcAEQj4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2016 11:39:56 -0500
In-Reply-To: <1452009433-22171-1-git-send-email-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/05/2016 04:57 PM, Craig Gallek wrote:
> From: Craig Gallek <kraig@google.com>
>
> Fixes: 538950a1b752 ("soreuseport: setsockopt SO_ATTACH_REUSEPORT_[CE]BPF")
> Suggested-by: Daniel Borkmann <daniel@iogearbox.net>
> Signed-off-by: Craig Gallek <kraig@google.com>

Thanks, Craig.

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
