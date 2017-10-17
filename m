From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 4/4] bpf: allow access to skb->len from offloads
Date: Tue, 17 Oct 2017 08:46:04 -0700
Message-ID: <20171017154603.rbffgx3spv4us27g@ast-mbp.dhcp.thefacebook.com>
References: <20171016234056.1964-1-jakub.kicinski@netronome.com>
 <20171016234056.1964-5-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        daniel@iogearbox.net
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:46933 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934307AbdJQPqH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 11:46:07 -0400
Received: by mail-pf0-f195.google.com with SMTP id p87so1632211pfj.3
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 08:46:07 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20171016234056.1964-5-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 16, 2017 at 04:40:56PM -0700, Jakub Kicinski wrote:
> Since we are now doing strict checking of what offloads
> may access, make sure skb->len is on that list.
> 
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>

Acked-by: Alexei Starovoitov <ast@kernel.org>
