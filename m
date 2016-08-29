From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFCv2 04/16] net: cls_bpf: add support for marking filters as
 hardware-only
Date: Mon, 29 Aug 2016 17:28:07 +0200
Message-ID: <57C45487.8090908@iogearbox.net>
References: <1472234775-29453-1-git-send-email-jakub.kicinski@netronome.com> <1472234775-29453-5-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, dinan.gunawardena@netronome.com, jiri@resnulli.us,
        john.fastabend@gmail.com, kubakici@wp.pl
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:46130 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933008AbcH2P2K (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 11:28:10 -0400
In-Reply-To: <1472234775-29453-5-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/26/2016 08:06 PM, Jakub Kicinski wrote:
> Add cls_bpf support for the TCA_CLS_FLAGS_SKIP_SW flag.
>
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
