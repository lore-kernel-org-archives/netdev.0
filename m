From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 3/3] samples/bpf: extend test_tunnel_bpf.sh with
 ERSPAN
Date: Wed, 23 Aug 2017 12:15:26 -0700
Message-ID: <20170823191524.clgyozkks2bou3ct@ast-mbp>
References: <1503500157-3717-1-git-send-email-u9012063@gmail.com>
 <1503500157-3717-3-git-send-email-u9012063@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: William Tu <u9012063@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:34663 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932458AbdHWTP3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 15:15:29 -0400
Received: by mail-pg0-f42.google.com with SMTP id s14so3938499pgs.1
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2017 12:15:29 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1503500157-3717-3-git-send-email-u9012063@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 23, 2017 at 07:55:57AM -0700, William Tu wrote:
> Extend existing tests for vxlan, gre, geneve, ipip to
> include ERSPAN tunnel.
> 
> Signed-off-by: William Tu <u9012063@gmail.com>

the test looks fine, hence
Acked-by: Alexei Starovoitov <ast@kernel.org>
cannot properly review patches 1,2, since I'm not familiar with erspan.
