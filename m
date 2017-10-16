From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next] tools: bpftool: use more common tag format
Date: Mon, 16 Oct 2017 14:52:48 -0700
Message-ID: <20171016215246.42p7plrgvfn7x4pn@ast-mbp.dhcp.thefacebook.com>
References: <20171016171254.26225-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        daniel@iogearbox.net
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:52616 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752107AbdJPVww (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 17:52:52 -0400
Received: by mail-pf0-f176.google.com with SMTP id e64so16771366pfk.9
        for <netdev@vger.kernel.org>; Mon, 16 Oct 2017 14:52:52 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20171016171254.26225-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 16, 2017 at 10:12:54AM -0700, Jakub Kicinski wrote:
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

thanks!
Acked-by: Alexei Starovoitov <ast@kernel.org>
