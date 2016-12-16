From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH] cgroup: Fix CGROUP_BPF config
Date: Fri, 16 Dec 2016 10:18:32 -0800
Message-ID: <20161216181830.GA80546@ast-mbp.thefacebook.com>
References: <8d48c3940f8d0275da6398ea5bcef14e20233db5.1481905995.git.luto@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Mack <daniel@zonque.org>,
        Network Development <netdev@vger.kernel.org>
To: Andy Lutomirski <luto@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35589 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756448AbcLPSSg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2016 13:18:36 -0500
Received: by mail-pg0-f65.google.com with SMTP id p66so10424447pga.2
        for <netdev@vger.kernel.org>; Fri, 16 Dec 2016 10:18:35 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <8d48c3940f8d0275da6398ea5bcef14e20233db5.1481905995.git.luto@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 16, 2016 at 08:33:45AM -0800, Andy Lutomirski wrote:
> CGROUP_BPF depended on SOCK_CGROUP_DATA which can't be manually
> enabled, making it rather challenging to turn CGROUP_BPF on.
> 
> Signed-off-by: Andy Lutomirski <luto@kernel.org>

Acked-by: Alexei Starovoitov <ast@kernel.org>
