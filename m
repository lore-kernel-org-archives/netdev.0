From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next v5 1/3] bpf: Refactor cgroups code in prep for
 new type
Date: Tue, 29 Nov 2016 11:41:54 -0800
Message-ID: <20161129194152.GA24152@ast-mbp.thefacebook.com>
References: <1480434813-3141-1-git-send-email-dsa@cumulusnetworks.com>
 <1480434813-3141-2-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, daniel@zonque.org, ast@fb.com,
        daniel@iogearbox.net, maheshb@google.com, tgraf@suug.ch
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:33718 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753974AbcK2Tl7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 14:41:59 -0500
Received: by mail-pg0-f66.google.com with SMTP id 3so17257281pgd.0
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 11:41:59 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1480434813-3141-2-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 29, 2016 at 07:53:31AM -0800, David Ahern wrote:
> Code move and rename only; no functional change intended.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Acked-by: Alexei Starovoitov <ast@kernel.org>
