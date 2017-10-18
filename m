From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [net PATCH 4/5] bpf: require CAP_NET_ADMIN when using sockmap
 maps
Date: Wed, 18 Oct 2017 10:34:24 -0700
Message-ID: <20171018173423.5p4hjlk4wxi6h3nb@ast-mbp>
References: <150833522977.3588.14633565129152334098.stgit@john-XPS-13-9360>
 <150833588223.3588.4249180141887196078.stgit@john-XPS-13-9360>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, borkmann@iogearbox.net
To: John Fastabend <john.r.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:51214 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751196AbdJRRe1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 13:34:27 -0400
Received: by mail-pg0-f43.google.com with SMTP id p9so4829102pgc.8
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 10:34:27 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <150833588223.3588.4249180141887196078.stgit@john-XPS-13-9360>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 18, 2017 at 07:11:22AM -0700, John Fastabend wrote:
> From: John Fastabend <john.fastabend@gmail.com>
> 
> Restrict sockmap to CAP_NET_ADMIN.
> 
> Signed-off-by: John Fastabend <john.fastabend@gmail.com>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>

Acked-by: Alexei Starovoitov <ast@kernel.org>
