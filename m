From: Lance Lassetter <lancelassetter@gmail.com>
Subject: Re: r8169 with 3.9.0-rc9
Date: Mon, 13 May 2013 22:04:34 -0500
Message-ID: <20130514030432.GA18292@gmail.com>
References: <20130427041230.GA18709@gmail.com>
 <20130428011232.GA4236@gmail.com>
 <20130501100733.GA16115@gmail.com>
 <20130501121502.GA5456@electric-eye.fr.zoreil.com>
 <20130501212803.GA3342@gmail.com>
 <20130501223155.GA15261@electric-eye.fr.zoreil.com>
 <20130502021848.GA30099@gmail.com>
 <20130502221837.GA9898@electric-eye.fr.zoreil.com>
 <20130505151732.GA9096@gmail.com>
 <20130505193323.GA21121@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f49.google.com ([209.85.213.49]:59538 "EHLO
	mail-yh0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751788Ab3ENDLX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 May 2013 23:11:23 -0400
Received: by mail-yh0-f49.google.com with SMTP id f73so6610yha.8
        for <netdev@vger.kernel.org>; Mon, 13 May 2013 20:11:22 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20130505193323.GA21121@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 05, 2013 at 09:33:23PM +0200, Francois Romieu wrote:
> Lance Lassetter <lancelassetter@gmail.com> :
> [...]
> > What do you think, Ueimor ?
> 
> I think you should try a post 3.9 kernel including commit
> 4ada8db38a44654446fe35ceb20a1972220e0f69 ("net: Restore NETIF_F_* bit
> ordering.").
> 
> -- 
> Ueimor

Ueimor,

Tried stock 3.10-rc1.  Still same problem with alias r8169 alias p10p1 and p8p1 "up down, up down".

Does this kernel inclde your patch?  I think it does....

Please reply with suggestions.

Regards,

Lance Lassetter
