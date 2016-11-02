From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: Re: [PATCH net-next 0/3] tools lib bpf: Synchronize implementations
Date: Wed, 2 Nov 2016 13:12:24 -0600
Message-ID: <20161102191224.GA5852@kernel.org>
References: <CAADnVQ+u5Q=+275nQCeHN2grk+kmRke9uJmMjRarA92UG7uGsA@mail.gmail.com>
 <20161102.150405.1790701106774926472.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexei.starovoitov@gmail.com, joe@ovn.org, netdev@vger.kernel.org,
        wangnan0@huawei.com, ast@fb.com, daniel@iogearbox.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:47142 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753245AbcKBTM2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 2 Nov 2016 15:12:28 -0400
Content-Disposition: inline
In-Reply-To: <20161102.150405.1790701106774926472.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Wed, Nov 02, 2016 at 03:04:05PM -0400, David Miller escreveu:
> From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
> Date: Tue, 1 Nov 2016 16:04:35 -0600
> 
> > I think these patches has to go through Arnaldo's perf tree, since
> > otherwise they will conflict with Wang's changes.
> 
> Ok.

I'll look at it when back from Plumbers, maybe before.

- Arnaldo
