From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v7 net-next 6/6] samples/bpf: add userspace example for
 prohibiting sockets
Date: Thu, 1 Dec 2016 08:58:25 -0800
Message-ID: <20161201165824.GF46200@ast-mbp.thefacebook.com>
References: <1480610888-31082-1-git-send-email-dsa@cumulusnetworks.com>
 <1480610888-31082-7-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, daniel@zonque.org, ast@fb.com,
        daniel@iogearbox.net, maheshb@google.com, tgraf@suug.ch
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35843 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759468AbcLAQ6a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 11:58:30 -0500
Received: by mail-pg0-f67.google.com with SMTP id x23so5134082pgx.3
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 08:58:30 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1480610888-31082-7-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 01, 2016 at 08:48:08AM -0800, David Ahern wrote:
> Add examples preventing a process in a cgroup from opening a socket
> based family, protocol and type.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Acked-by: Alexei Starovoitov <ast@kernel.org>
