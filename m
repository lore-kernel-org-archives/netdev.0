From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 0/8] tools: bpftool: add a "version" command,
 and fix several items
Date: Thu, 19 Oct 2017 16:42:24 -0700
Message-ID: <20171019234222.bdpiucnbqg54looh@ast-mbp>
References: <20171019224626.31608-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:48999 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751601AbdJSXm1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 19:42:27 -0400
Received: by mail-pf0-f193.google.com with SMTP id b79so8290387pfk.5
        for <netdev@vger.kernel.org>; Thu, 19 Oct 2017 16:42:27 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20171019224626.31608-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 19, 2017 at 03:46:18PM -0700, Jakub Kicinski wrote:
> Quentin says:
> 
> The first seven patches of this series bring several minor fixes to
> bpftool. Please see individual commit logs for details.
> 
> Last patch adds a "version" commands to bpftool, which is in fact the
> version of the kernel from which it was compiled.

lgtm
Acked-by: Alexei Starovoitov <ast@kernel.org>
