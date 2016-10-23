From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH v7] net: ip, diag -- Add diag interface for raw sockets
Date: Sun, 23 Oct 2016 10:12:09 +0300
Message-ID: <20161023071209.GO1847@uranus.lan>
References: <20161021100344.GM1847@uranus.lan>
 <20161022.185527.935058828725905432.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, dsa@cumulusnetworks.com,
        eric.dumazet@gmail.com, jhs@mojatatu.com,
        linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
        avagin@openvz.org, stephen@networkplumber.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161022.185527.935058828725905432.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 22, 2016 at 06:55:27PM -0400, David Miller wrote:
> From: Cyrill Gorcunov <gorcunov@gmail.com>
> Date: Fri, 21 Oct 2016 13:03:44 +0300
> 
> > In criu we are actively using diag interface to collect sockets
> > present in the system when dumping applications. And while for
> > unix, tcp, udp[lite], packet, netlink it works as expected,
> > the raw sockets do not have. Thus add it.
> 
> Applied, thanks.

Thanks to all for extensive comments and review!
