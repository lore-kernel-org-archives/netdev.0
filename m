From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] mlx5: remove dead code
Date: Mon, 30 Dec 2013 15:56:10 +0400
Message-ID: <52C15F5A.80601@cogentembedded.com>
References: <20131229135137.7a8566da@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>,
	Eli Cohen <eli@mellanox.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:49999 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754728Ab3L3L4O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Dec 2013 06:56:14 -0500
Received: by mail-la0-f42.google.com with SMTP id ec20so5608104lab.29
        for <netdev@vger.kernel.org>; Mon, 30 Dec 2013 03:56:12 -0800 (PST)
In-Reply-To: <20131229135137.7a8566da@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 30-12-2013 1:51, Stephen Hemminger wrote:

> There are 3 functions in the mlx5 driver which are used and should be

    s/used/unused/, I think.

> deleted. Upstream is not the repository to hold old dead code, or code
> which is used by outside drivers, or code intended for future undetermined
> features.

> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

WBR, Sergei
