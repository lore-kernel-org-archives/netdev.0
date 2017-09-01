From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] bpf: Collapse offset checks in sock_filter_is_valid_access
Date: Fri, 01 Sep 2017 17:53:12 +0200
Message-ID: <59A98268.40509@iogearbox.net>
References: <1504279087-11379-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: David Ahern <dsahern@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41340 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752010AbdIAPxO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 11:53:14 -0400
In-Reply-To: <1504279087-11379-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/01/2017 05:18 PM, David Ahern wrote:
> Make sock_filter_is_valid_access consistent with other is_valid_access
> helpers.
>
> Requested-by: Daniel Borkmann <daniel@iogearbox.net>
> Signed-off-by: David Ahern <dsahern@gmail.com>

Thanks for following up,

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
