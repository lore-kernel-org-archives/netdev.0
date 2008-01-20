From: "Jesper Juhl" <jesper.juhl@gmail.com>
Subject: Re: [PATCH] [IrDA] af_irda memory leak fixes
Date: Sun, 20 Jan 2008 01:23:22 +0100
Message-ID: <9a8748490801191623y22af5b7fi78e33e5acbdcf33e@mail.gmail.com>
References: <20080118075322.GB3063@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	irda-users@lists.sourceforge.net, netdev@vger.kernel.org
To: "Samuel Ortiz" <samuel@sortiz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.182]:19282 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758927AbYATAXZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jan 2008 19:23:25 -0500
Received: by wa-out-1112.google.com with SMTP id v27so2676764wah.23
        for <netdev@vger.kernel.org>; Sat, 19 Jan 2008 16:23:22 -0800 (PST)
In-Reply-To: <20080118075322.GB3063@sortiz.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18/01/2008, Samuel Ortiz <samuel@sortiz.org> wrote:
> Hi Dave,
>
> Here goes an IrDA patch against your latest net-2.6 tree.
>
> This patch fixes some af_irda memory leaks.
> It also checks for irias_new_obect() return value.
>
> Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
> Signed-off-by: Samuel Ortiz <samuel@sortiz.org>
...

Looks good Samuel.
Thank you for improving on my original suggested patch.

Now let's hope someone queues it up for mainline :)

-- 
Jesper Juhl <jesper.juhl@gmail.com>
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please      http://www.expita.com/nomime.html
