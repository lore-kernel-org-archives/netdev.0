From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 -master 0/2] Two misc BPF updates
Date: Tue, 30 May 2017 17:49:56 -0700
Message-ID: <20170530174956.65b86488@xeon-e3>
References: <cover.1494635217.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:34680 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750925AbdEaAt7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 20:49:59 -0400
Received: by mail-pf0-f180.google.com with SMTP id 9so2078121pfj.1
        for <netdev@vger.kernel.org>; Tue, 30 May 2017 17:49:58 -0700 (PDT)
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

Applied thanks.
