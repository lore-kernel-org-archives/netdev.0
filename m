From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 -master 0/2] Two misc BPF updates
Date: Mon, 15 May 2017 15:07:41 -0700
Message-ID: <20170515150741.645e25f5@xeon-e3>
References: <cover.1494635217.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:36681 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751068AbdEOWHo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 18:07:44 -0400
Received: by mail-pg0-f48.google.com with SMTP id x64so46931449pgd.3
        for <netdev@vger.kernel.org>; Mon, 15 May 2017 15:07:44 -0700 (PDT)
In-Reply-To: <cover.1494635217.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 13 May 2017 02:32:33 +0200
Daniel Borkmann <daniel@iogearbox.net> wrote:

> Requires header rebase with -net.
> 
> Thanks!
> 
> Daniel Borkmann (2):
>   bpf: update printing of generic xdp mode
>   bpf: dump error to the user when retrieving pinned prog fails
> 
>  ip/iplink_xdp.c | 19 +++++++++++--------
>  lib/bpf.c       | 12 +++++++++++-
>  2 files changed, 22 insertions(+), 9 deletions(-)
> 

Holding off until Linus pulls net
