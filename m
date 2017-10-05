From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCH net-next v4 0/3] tools: add bpftool
Date: Thu, 5 Oct 2017 09:02:55 -0700
Message-ID: <20171005090255.25eb90d1@cakuba.netronome.com>
References: <20171005031005.15364-1-jakub.kicinski@netronome.com>
        <20171004.214647.434421323387588461.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net, dsahern@gmail.com, oss-drivers@netronome.com,
        brouer@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f176.google.com ([209.85.216.176]:52967 "EHLO
        mail-qt0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751424AbdJEQC7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2017 12:02:59 -0400
Received: by mail-qt0-f176.google.com with SMTP id o52so26274611qtc.9
        for <netdev@vger.kernel.org>; Thu, 05 Oct 2017 09:02:59 -0700 (PDT)
In-Reply-To: <20171004.214647.434421323387588461.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 04 Oct 2017 21:46:47 -0700 (PDT), David Miller wrote:
> From: Jakub Kicinski <jakub.kicinski@netronome.com>
> Date: Wed,  4 Oct 2017 20:10:02 -0700
> 
> > Hi!
> > 
> > This set adds bpftool to the tools/ directory.  The first 
> > patch renames tools/net to tools/bpf, the second one adds 
> > the new code, while the third adds simple documentation.
> > 
> > v4:
> >  - rename docs *.txt -> *.rst (Jesper).
> > v3:
> >  - address Alexei's comments about output and docs.
> > v2:
> >  - report names, map ids, load time, uid;
> >  - add docs/man pages;
> >  - general cleanups & fixes.  
> 
> Series applied, although there was some trailing whitespace I had to fix
> up in patch #3.

I was under the impression that the white space was required by the RST
format, but I double checked and the man page looks correct.

Thank you!
