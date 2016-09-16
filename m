From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCHv5 net-next 04/15] bpf: don't (ab)use instructions to store
 state
Date: Fri, 16 Sep 2016 23:22:00 +0200
Message-ID: <57DC6278.8090604@iogearbox.net>
References: <1474018622-10653-1-git-send-email-jakub.kicinski@netronome.com> <1474018622-10653-5-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:40593 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754074AbcIPVWD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2016 17:22:03 -0400
In-Reply-To: <1474018622-10653-5-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/16/2016 11:36 AM, Jakub Kicinski wrote:
> Storing state in reserved fields of instructions makes
> it impossible to run verifier on programs already
> marked as read-only. Allocate and use an array of
> per-instruction state instead.
>
> While touching the error path rename and move existing
> jump target.
>
> Suggested-by: Alexei Starovoitov <ast@kernel.org>
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> Acked-by: Alexei Starovoitov <ast@kernel.org>

LGMT

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
