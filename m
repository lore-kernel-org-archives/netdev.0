From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCHv5 net-next 05/15] bpf: expose internal verfier structures
Date: Sat, 17 Sep 2016 00:47:03 +0200
Message-ID: <57DC7667.3020504@iogearbox.net>
References: <1474018622-10653-1-git-send-email-jakub.kicinski@netronome.com> <1474018622-10653-6-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:49070 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752920AbcIPWrH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2016 18:47:07 -0400
In-Reply-To: <1474018622-10653-6-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/16/2016 11:36 AM, Jakub Kicinski wrote:
> Move verifier's internal structures to a header file and
> prefix their names with bpf_ to avoid potential namespace
> conflicts.  Those structures will soon be used by external
> analyzers.
>
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> Acked-by: Alexei Starovoitov <ast@kernel.org>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
