From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tools: bpftool: use more common tag format
Date: Wed, 18 Oct 2017 13:20:00 +0100 (WEST)
Message-ID: <20171018.132000.1743823734744390065.davem@davemloft.net>
References: <20171016171254.26225-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        alexei.starovoitov@gmail.com, daniel@iogearbox.net
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60508 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935346AbdJRMUH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 08:20:07 -0400
In-Reply-To: <20171016171254.26225-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Mon, 16 Oct 2017 10:12:54 -0700

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

Applied.
