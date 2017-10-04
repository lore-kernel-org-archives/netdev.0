From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH net-next v2 0/3] tools: add bpftool
Date: Tue, 3 Oct 2017 17:48:22 -0700
Message-ID: <20171003174822.214e4337@cakuba>
References: <20171002231130.12406-1-jakub.kicinski@netronome.com>
        <20171003201942.GH25388@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
        alexei.starovoitov@gmail.com, oss-drivers@netronome.com
To: Arnaldo Carvalho de Melo <acme@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.11]:10111 "EHLO mx4.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750865AbdJDAsa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Oct 2017 20:48:30 -0400
In-Reply-To: <20171003201942.GH25388@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 3 Oct 2017 17:19:42 -0300, Arnaldo Carvalho de Melo wrote:
> Em Mon, Oct 02, 2017 at 04:11:27PM -0700, Jakub Kicinski escreveu:
> > Hi!
> > 
> > This set adds bpftool to the tools/ directory.  The first 
> > patch renames tools/net to tools/bpf, the second one adds 
> > the new code, while the third adds simple documentation.
> > 
> > v2:
> >  - report names, map ids, load time, uid;
> >  - add docs/man pages;
> >  - general cleanups & fixes.
> > 
> > Thanks to David Beckett for help with docs and testing.  
> 
> Why not call it just 'bpf'?

bpftool was suggested as a better name, I don't really mind either way.
