From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 01/12] tools: bpftool: copy JSON writer from
 iproute2 repository
Date: Tue, 24 Oct 2017 10:23:38 +0200
Message-ID: <20171024102338.738d68cb@shemminger-XPS-13-9360>
References: <20171023162416.32753-1-jakub.kicinski@netronome.com>
        <20171023162416.32753-2-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        alexei.starovoitov@gmail.com, daniel@iogearbox.net,
        Quentin Monnet <quentin.monnet@netronome.com>
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:51514 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751323AbdJXIXv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 04:23:51 -0400
Received: by mail-wr0-f193.google.com with SMTP id j15so7654219wre.8
        for <netdev@vger.kernel.org>; Tue, 24 Oct 2017 01:23:50 -0700 (PDT)
In-Reply-To: <20171023162416.32753-2-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 23 Oct 2017 09:24:05 -0700
Jakub Kicinski <jakub.kicinski@netronome.com> wrote:

> From: Quentin Monnet <quentin.monnet@netronome.com>
> 
> In prevision of following commits, supposed to add JSON output to the
> tool, two files are copied from the iproute2 repository (taken at commit
> 268a9eee985f): lib/json_writer.c and include/json_writer.h.
> 
> Signed-off-by: Quentin Monnet <quentin.monnet@netronome.com>

Acked-by: Stephen Hemminger <stephen@networkplumber.org>
