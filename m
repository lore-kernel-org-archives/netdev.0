From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [net-next PATCH 4/9] bpf: additional sockmap self tests
Date: Mon, 28 Aug 2017 10:36:12 -0700
Message-ID: <20170828173611.bkq4hdyadt3ji6tt@ast-mbp>
References: <20170828140850.14143.83953.stgit@john-Precision-Tower-5810>
 <20170828141105.14143.31609.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ast@kernel.org, daniel@iogearbox.net, davem@davemloft.net,
        netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:34894 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751161AbdH1RgP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 13:36:15 -0400
Received: by mail-pf0-f182.google.com with SMTP id g13so3130057pfm.2
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 10:36:14 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170828141105.14143.31609.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 28, 2017 at 07:11:05AM -0700, John Fastabend wrote:
> Add some more sockmap tests to cover,
> 
>  - forwarding to NULL entries
>  - more than two maps to test list ops
>  - forwarding to different map
> 
> Signed-off-by: John Fastabend <john.fastabend@gmail.com>

Acked-by: Alexei Starovoitov <ast@kernel.org>
