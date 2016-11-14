From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v2 net-next 3/6] bpf: Refactor codes handling percpu map
Date: Mon, 14 Nov 2016 10:43:13 -0800
Message-ID: <20161114184311.GA99268@ast-mbp.thefacebook.com>
References: <1478890511-1346984-1-git-send-email-kafai@fb.com>
 <1478890511-1346984-4-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Kernel Team <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36194 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754676AbcKNSnS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2016 13:43:18 -0500
Received: by mail-pg0-f68.google.com with SMTP id x23so9578637pgx.3
        for <netdev@vger.kernel.org>; Mon, 14 Nov 2016 10:43:17 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1478890511-1346984-4-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 11, 2016 at 10:55:08AM -0800, Martin KaFai Lau wrote:
> Refactor the codes that populate the value
> of a htab_elem in a BPF_MAP_TYPE_PERCPU_HASH
> typed bpf_map.
> 
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>

Acked-by: Alexei Starovoitov <ast@kernel.org>
