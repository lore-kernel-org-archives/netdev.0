From: Patrick McHardy <kaber@trash.net>
Subject: Re: [2.6 patch] rtnetlink.c: #if 0 no longer used functions
Date: Wed, 30 Jan 2008 21:04:33 +0100
Message-ID: <47A0D851.9050408@trash.net>
References: <20080130200257.GD29368@does.not.exist>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60245 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754196AbYA3UFJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2008 15:05:09 -0500
In-Reply-To: <20080130200257.GD29368@does.not.exist>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adrian Bunk wrote:
> This patch #if 0's the following no longer used functions:
> - rtattr_parse()
> - rtattr_strlcpy()
> - __rtattr_parse_nested_compat()
>   

Please remove them instead.
