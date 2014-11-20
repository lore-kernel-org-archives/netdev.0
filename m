From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH net-next V1 0/2] ethtool, net/mlx4_en: RSS hash function selection
Date: Thu, 20 Nov 2014 16:34:20 +0200
Message-ID: <CAPcc5Pgx728vJqXSUEapD61REYsSzpZ8YTSqJRkp3976_Xw7NQ@mail.gmail.com>
References: <1416493610-8966-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Ben Hutchings <ben@decadent.org.uk>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:55725 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751257AbaKTOeV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2014 09:34:21 -0500
Received: by mail-wi0-f173.google.com with SMTP id r20so8918202wiv.0
        for <netdev@vger.kernel.org>; Thu, 20 Nov 2014 06:34:20 -0800 (PST)
In-Reply-To: <1416493610-8966-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 20, 2014 at 4:26 PM, Amir Vadai <amirv@mellanox.com> wrote:
> Hi,
>
> This patchset by Eyal adds support in set/get of RSS hash function. Current
> supported functions are Toeplitz and XOR. The API is design to enable adding
> new hash functions without breaking backward compatibility.
> Userspace patch will be sent after API is available in kernel.
>
> The patchset was applied and tested over commit 7b909bb ("Merge branches
> 'core', 'cxgb4', 'iser', 'mlx5' and 'ocrdma' into for-next")
Should be commit daaf427 ("bpf: fix arraymap NULL deref and missing
overflow and zero size checks")

>
> Amir
>

[...]
