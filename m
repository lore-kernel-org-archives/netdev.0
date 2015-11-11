From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [iproute PATCH v2 6/6] iptoken: simplify iptoken_list a bit
Date: Wed, 11 Nov 2015 12:03:47 +0100
Message-ID: <56432093.7000702@iogearbox.net>
References: <1447010471-559-1-git-send-email-phil@nwl.cc> <1447014141-3565-1-git-send-email-phil@nwl.cc> <1447014141-3565-7-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>, Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:56433 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751621AbbKKLDv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2015 06:03:51 -0500
In-Reply-To: <1447014141-3565-7-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/08/2015 09:22 PM, Phil Sutter wrote:
> Since it uses only a single filter, rtnl_dump_filter() can be used.
>
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
