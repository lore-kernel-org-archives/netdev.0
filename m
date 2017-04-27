From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] Fix inaccurate helper function description
Date: Thu, 27 Apr 2017 13:10:27 +0200
Message-ID: <5901D1A3.9090207@iogearbox.net>
References: <1493250083-1954-1-git-send-email-chenbofeng.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mic@digikod.net,
        Chenbo Feng <fengc@google.com>
To: Chenbo Feng <chenbofeng.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:53878 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936152AbdD0LKj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 07:10:39 -0400
In-Reply-To: <1493250083-1954-1-git-send-email-chenbofeng.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/27/2017 01:41 AM, Chenbo Feng wrote:
> From: Chenbo Feng <fengc@google.com>
>
> The description inside uapi/linux/bpf.h about bpf_get_socket_uid
> helper function is no longer valid. It returns overflowuid rather
> than 0 when failed.
>
> Signed-off-by: Chenbo Feng <fengc@google.com>

"bpf: " prefix in patch subject line would have been good.

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
