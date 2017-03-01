From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH] bpf: update the comment about the length of analysis
Date: Wed, 1 Mar 2017 09:15:30 -0800
Message-ID: <20170301171528.GA15248@ast-mbp.thefacebook.com>
References: <20170301082551.7388-1-glin@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>
To: Gary Lin <glin@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34064 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751099AbdCARQA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Mar 2017 12:16:00 -0500
Content-Disposition: inline
In-Reply-To: <20170301082551.7388-1-glin@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 01, 2017 at 04:25:51PM +0800, Gary Lin wrote:
> Commit 07016151a446 ("bpf, verifier: further improve search
> pruning") increased the limit of processed instructions from
> 32k to 64k, but the comment still mentioned the 32k limit.
> This commit updates the comment to reflect the change.
> 
> Cc: Alexei Starovoitov <ast@kernel.org>
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Signed-off-by: Gary Lin <glin@suse.com>

Acked-by: Alexei Starovoitov <ast@kernel.org>
