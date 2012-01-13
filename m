From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pptp: Accept packet with seq zero
Date: Thu, 12 Jan 2012 20:06:18 -0800 (PST)
Message-ID: <20120112.200618.1500624575730438380.davem@davemloft.net>
References: <1326400756-14021-1-git-send-email-despite@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xeb@mail.ru, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: despite@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1326400756-14021-1-git-send-email-despite@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bradley Peterson <despite@gmail.com>
Date: Thu, 12 Jan 2012 14:39:16 -0600

> Initialize the PPTP "seq received" value to 0xffffffff, so we don't
> ignore packets with seq zero.
> 
> Signed-off-by: Bradley Peterson <despite@gmail.com>

Applied.
