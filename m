From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v7] net: ip, diag -- Add diag interface for raw sockets
Date: Sat, 22 Oct 2016 18:55:27 -0400 (EDT)
Message-ID: <20161022.185527.935058828725905432.davem@davemloft.net>
References: <20161021100344.GM1847@uranus.lan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dsa@cumulusnetworks.com,
        eric.dumazet@gmail.com, jhs@mojatatu.com,
        linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
        avagin@openvz.org, stephen@networkplumber.org
To: gorcunov@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161021100344.GM1847@uranus.lan>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Cyrill Gorcunov <gorcunov@gmail.com>
Date: Fri, 21 Oct 2016 13:03:44 +0300

> In criu we are actively using diag interface to collect sockets
> present in the system when dumping applications. And while for
> unix, tcp, udp[lite], packet, netlink it works as expected,
> the raw sockets do not have. Thus add it.

Applied, thanks.
