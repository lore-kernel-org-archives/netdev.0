From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] ipv4: fix NULL pointer dereference in
 __inet_put_port()
Date: Tue, 29 Mar 2016 16:53:38 -0400 (EDT)
Message-ID: <20160329.165338.1302307765533317960.davem@davemloft.net>
References: <1459233953-4745-1-git-send-email-fanhui00@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: fanhui00@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1459233953-4745-1-git-send-email-fanhui00@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: fanhui <fanhui00@gmail.com>
Date: Tue, 29 Mar 2016 14:45:53 +0800

> [<ffffffc000930718>] tcp_nuke_addr+0x22c/0x2a0

Do not report or fix problems in non-mainline kernels.

Thank you.
