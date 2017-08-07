From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] selftests: bpf: add a test for XDP redirect
Date: Mon, 07 Aug 2017 23:26:56 +0200
Message-ID: <5988DB20.2000102@iogearbox.net>
References: <1502136882-40204-1-git-send-email-u9012063@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>
To: William Tu <u9012063@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:59347 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751662AbdHGV06 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 17:26:58 -0400
In-Reply-To: <1502136882-40204-1-git-send-email-u9012063@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/07/2017 10:14 PM, William Tu wrote:
> Add test for xdp_redirect by creating two namespaces with two
> veth peers, then forward packets in-between.
>
> Signed-off-by: William Tu <u9012063@gmail.com>
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Cc: John Fastabend <john.fastabend@gmail.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
