From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pptp: use idr for allocation of callids
Date: Thu, 05 Nov 2015 15:12:48 -0500 (EST)
Message-ID: <20151105.151248.1982764713298691007.davem@davemloft.net>
References: <1446754064-1195-1-git-send-email-sasha.levin@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xeb@mail.ru, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: sasha.levin@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1446754064-1195-1-git-send-email-sasha.levin@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sasha Levin <sasha.levin@oracle.com>
Date: Thu,  5 Nov 2015 15:07:44 -0500

> The current implementation used a bitfield with a corresponding array to
> manage assignment of call ids. Rather than open-coding it, use IDR for
> this.
> 
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>

Please resubmit this when the net-next tree opens back up, thanks.
