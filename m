From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: Re: [PATCH net-next v2 0/3] tools: add bpftool
Date: Wed, 4 Oct 2017 08:40:33 -0300
Message-ID: <20171004114033.GJ25388@kernel.org>
References: <20171002231130.12406-1-jakub.kicinski@netronome.com>
 <20171003201942.GH25388@kernel.org>
 <20171003174822.214e4337@cakuba>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
        alexei.starovoitov@gmail.com, oss-drivers@netronome.com
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:42868 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751449AbdJDLkl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 4 Oct 2017 07:40:41 -0400
Content-Disposition: inline
In-Reply-To: <20171003174822.214e4337@cakuba>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Tue, Oct 03, 2017 at 05:48:22PM -0700, Jakub Kicinski escreveu:
> On Tue, 3 Oct 2017 17:19:42 -0300, Arnaldo Carvalho de Melo wrote:
> > Why not call it just 'bpf'?
 
> bpftool was suggested as a better name, I don't really mind either way.

I just thought that 'bpf' isn't used as a command, shorter, less typing,
but yeah, if people think having 'tool' in the tool name helps somewhat,
so be it.

- Arnaldo
