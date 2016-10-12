From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH iproute2] tc: cls_bpf: handle skip_sw and skip_hw flags
Date: Wed, 12 Oct 2016 18:03:19 +0200
Message-ID: <57FE5EC7.3010405@iogearbox.net>
References: <1476287196-28931-1-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:45505 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755360AbcJLQDW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2016 12:03:22 -0400
In-Reply-To: <1476287196-28931-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/12/2016 05:46 PM, Jakub Kicinski wrote:
> Add support for controling hardware offload using (now standard)
> skip_sw and skip_hw flags in cls_bpf.
>
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
