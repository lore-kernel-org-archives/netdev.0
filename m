From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: More painful merges...
Date: Mon, 30 Oct 2017 08:14:31 -0700
Message-ID: <20171030151429.mdcvyxflhmrtvfah@ast-mbp.dhcp.thefacebook.com>
References: <20171030.211551.790664985307439262.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, john.fastabend@gmail.com, ast@kernel.org,
        daniel@iogearbox.net, xiyou.wangcong@gmail.com, jiri@mellanox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:46625 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752456AbdJ3POe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 11:14:34 -0400
Received: by mail-pf0-f175.google.com with SMTP id p87so11257913pfj.3
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 08:14:34 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20171030.211551.790664985307439262.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 30, 2017 at 09:15:51PM +0900, David Miller wrote:
> 
> BPF and tc action bug fixes in 'net' caused some extremely
> painful merges with 'net-next'.
> 
> Could the interested parties please take a look at 'net-next'
> and send me any necessary fixes, as I did the best that I
> could.

bpf side is good. John, please double check as well.
