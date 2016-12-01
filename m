From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v7 net-next 5/6] samples/bpf: Update bpf loader for
 cgroup section names
Date: Thu, 1 Dec 2016 08:58:03 -0800
Message-ID: <20161201165751.GE46200@ast-mbp.thefacebook.com>
References: <1480610888-31082-1-git-send-email-dsa@cumulusnetworks.com>
 <1480610888-31082-6-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, daniel@zonque.org, ast@fb.com,
        daniel@iogearbox.net, maheshb@google.com, tgraf@suug.ch
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34870 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758348AbcLAQ6R (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 11:58:17 -0500
Received: by mail-pg0-f65.google.com with SMTP id p66so5134215pga.2
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 08:58:07 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1480610888-31082-6-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 01, 2016 at 08:48:07AM -0800, David Ahern wrote:
> Add support for section names starting with cgroup/skb and cgroup/sock.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Acked-by: Alexei Starovoitov <ast@kernel.org>
