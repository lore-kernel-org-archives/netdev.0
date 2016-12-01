From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v7 net-next 3/6] samples: bpf: add userspace example for
 modifying sk_bound_dev_if
Date: Thu, 1 Dec 2016 08:57:02 -0800
Message-ID: <20161201165701.GC46200@ast-mbp.thefacebook.com>
References: <1480610888-31082-1-git-send-email-dsa@cumulusnetworks.com>
 <1480610888-31082-4-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, daniel@zonque.org, ast@fb.com,
        daniel@iogearbox.net, maheshb@google.com, tgraf@suug.ch
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33901 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757429AbcLAQ5t (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 11:57:49 -0500
Received: by mail-pf0-f195.google.com with SMTP id y68so12199850pfb.1
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 08:57:07 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1480610888-31082-4-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 01, 2016 at 08:48:05AM -0800, David Ahern wrote:
> Add a simple program to demonstrate the ability to attach a bpf program
> to a cgroup that sets sk_bound_dev_if for AF_INET{6} sockets when they
> are created.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Acked-by: Alexei Starovoitov <ast@kernel.org>
