From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net-next v4 0/3] tools: add bpftool
Date: Wed, 4 Oct 2017 20:26:01 -0700
Message-ID: <aa472a38-5293-c0c0-4476-117dfa169f1d@gmail.com>
References: <20171005031005.15364-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, daniel@iogearbox.net,
        oss-drivers@netronome.com, brouer@redhat.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:49649 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751223AbdJED0G (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 23:26:06 -0400
Received: by mail-pg0-f49.google.com with SMTP id v13so7591876pgq.6
        for <netdev@vger.kernel.org>; Wed, 04 Oct 2017 20:26:05 -0700 (PDT)
In-Reply-To: <20171005031005.15364-1-jakub.kicinski@netronome.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/4/17 8:10 PM, Jakub Kicinski wrote:
> Hi!
> 
> This set adds bpftool to the tools/ directory.  The first 
> patch renames tools/net to tools/bpf, the second one adds 
> the new code, while the third adds simple documentation.
> 
> v4:
>  - rename docs *.txt -> *.rst (Jesper).
> v3:
>  - address Alexei's comments about output and docs.
> v2:
>  - report names, map ids, load time, uid;
>  - add docs/man pages;
>  - general cleanups & fixes.
> 
> Jakub Kicinski (3):
>   tools: rename tools/net directory to tools/bpf
>   tools: bpf: add bpftool
>   tools: bpftool: add documentation
> 

LGTM. Thanks for the work, Jakub.

Acked-by: David Ahern <dsahern@gmail.com>
