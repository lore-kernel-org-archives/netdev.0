From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH] bpf: testing: fix devmap tests
Date: Wed, 26 Jul 2017 17:35:41 -0700
Message-ID: <5979355D.60807@gmail.com>
References: <20170727003206.16649.50637.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: jakub.kicinski@netronome.com, daniel@iogearbox.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:33020 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751202AbdG0Afu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2017 20:35:50 -0400
Received: by mail-pf0-f179.google.com with SMTP id d67so8974634pfc.0
        for <netdev@vger.kernel.org>; Wed, 26 Jul 2017 17:35:50 -0700 (PDT)
In-Reply-To: <20170727003206.16649.50637.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/26/2017 05:32 PM, John Fastabend wrote:
> Apparently through one of my revisions of the initial patches
> series I lost the devmap test. We can add more testing later but
> for now lets fix the simple one we have.
> 
> Fixes: 546ac1ffb70d "bpf: add devmap, a map for storing net device references"
> Reported-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> Signed-off-by: John Fastabend <john.fastabend@gmail.com>
> ---

Forgot prefix, this is for net-next. Sorry about that.

Thanks,
John
