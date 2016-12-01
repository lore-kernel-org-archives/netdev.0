From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v7 net-next 1/6] bpf: Refactor cgroups code in prep for
 new type
Date: Thu, 1 Dec 2016 08:56:18 -0800
Message-ID: <20161201165616.GA46200@ast-mbp.thefacebook.com>
References: <1480610888-31082-1-git-send-email-dsa@cumulusnetworks.com>
 <1480610888-31082-2-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, daniel@zonque.org, ast@fb.com,
        daniel@iogearbox.net, maheshb@google.com, tgraf@suug.ch
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:36036 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758739AbcLAQ42 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 11:56:28 -0500
Received: by mail-pg0-f66.google.com with SMTP id x23so5129183pgx.3
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 08:56:23 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1480610888-31082-2-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 01, 2016 at 08:48:03AM -0800, David Ahern wrote:
> Code move and rename only; no functional change intended.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Acked-by: Alexei Starovoitov <ast@kernel.org>
