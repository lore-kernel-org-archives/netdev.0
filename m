From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next] bpf: Collapse offset checks in
 sock_filter_is_valid_access
Date: Fri, 1 Sep 2017 09:35:34 -0700
Message-ID: <20170901163533.nwzjkjiow5m2n4nn@ast-mbp.dhcp.thefacebook.com>
References: <1504279087-11379-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, daniel@iogearbox.net
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:32952 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752005AbdIAQfi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 12:35:38 -0400
Received: by mail-pf0-f173.google.com with SMTP id n73so1998916pfj.0
        for <netdev@vger.kernel.org>; Fri, 01 Sep 2017 09:35:37 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1504279087-11379-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 01, 2017 at 08:18:07AM -0700, David Ahern wrote:
> Make sock_filter_is_valid_access consistent with other is_valid_access
> helpers.
> 
> Requested-by: Daniel Borkmann <daniel@iogearbox.net>
> Signed-off-by: David Ahern <dsahern@gmail.com>

Acked-by: Alexei Starovoitov <ast@kernel.org>
