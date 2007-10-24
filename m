From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [2.6 patch] make tcp_match_skb_to_sack() static
Date: Thu, 25 Oct 2007 00:39:23 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0710242102530.11009@kivilampi-30.cs.helsinki.fi>
References: <20071024162358.GA30533@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: Adrian Bunk <bunk@kernel.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:45013 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753745AbXJXVkg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Oct 2007 17:40:36 -0400
In-Reply-To: <20071024162358.GA30533@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 24 Oct 2007, Adrian Bunk wrote:

> tcp_match_skb_to_sack() can become static.
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>
>
[...snip...]

Thanks, I should have noticed that right from the beginning...

Added DaveM to recipients.

-- 
 i.
