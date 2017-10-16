From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] tools: bpftool: use more common tag format
Date: Mon, 16 Oct 2017 20:02:00 +0200
Message-ID: <59E4F418.5040805@iogearbox.net>
References: <20171016171254.26225-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: oss-drivers@netronome.com, alexei.starovoitov@gmail.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:39932 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752949AbdJPSCD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 14:02:03 -0400
In-Reply-To: <20171016171254.26225-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/16/2017 07:12 PM, Jakub Kicinski wrote:
> Program tag is usually displayed as string of bytes without
> any separators (e.g. as "aa5520b1090cfeb6" vs MAC addr-like
> format bpftool uses currently: "aa:55:20:b1:09:0c:fe:b6").
> Make bptfool use the more common format both for displaying
> the tag and selecting the program by tag.
>
> This was pointed out in review but I misunderstood the comment.
>
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> Reviewed-by: Simon Horman <simon.horman@netronome.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
