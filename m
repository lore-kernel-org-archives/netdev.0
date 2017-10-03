From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFC 1/2] bpf: move instruction printing into a separate file
Date: Tue, 03 Oct 2017 21:32:05 +0200
Message-ID: <59D3E5B5.6020205@iogearbox.net>
References: <59D3B456.4020209@iogearbox.net> <20171003175746.30145-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        david.beckett@netronome.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>, dsahern@gmail.com,
        alexei.starovoitov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:42496 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751238AbdJCTcH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 15:32:07 -0400
In-Reply-To: <20171003175746.30145-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/03/2017 07:57 PM, Jakub Kicinski wrote:
> Separate the instruction printing into a standalone source file.
> This way sneaky code from tools/ can use it directly.
>
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> ---
> Like this?

Looks good to me, yes.
