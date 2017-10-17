From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 2/4] bpf: remove the verifier ops from program
 structure
Date: Tue, 17 Oct 2017 11:38:10 +0200
Message-ID: <59E5CF82.302@iogearbox.net>
References: <20171016234056.1964-1-jakub.kicinski@netronome.com> <20171016234056.1964-3-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: oss-drivers@netronome.com, alexei.starovoitov@gmail.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41264 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754717AbdJQJiL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 05:38:11 -0400
In-Reply-To: <20171016234056.1964-3-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/17/2017 01:40 AM, Jakub Kicinski wrote:
> Since the verifier ops don't have to be associated with
> the program for its entire lifetime we can move it to
> verifier's struct bpf_verifier_env.
>
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
