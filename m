From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH] bpf: testing: fix devmap tests
Date: Thu, 27 Jul 2017 02:40:28 +0200
Message-ID: <5979367C.4020408@iogearbox.net>
References: <20170727003206.16649.50637.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, jakub.kicinski@netronome.com
To: John Fastabend <john.fastabend@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:48119 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751202AbdG0Aka (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2017 20:40:30 -0400
In-Reply-To: <20170727003206.16649.50637.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/27/2017 02:32 AM, John Fastabend wrote:
> Apparently through one of my revisions of the initial patches
> series I lost the devmap test. We can add more testing later but
> for now lets fix the simple one we have.
>
> Fixes: 546ac1ffb70d "bpf: add devmap, a map for storing net device references"
> Reported-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> Signed-off-by: John Fastabend <john.fastabend@gmail.com>

Looks good, thanks!

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
