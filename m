From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: tcp compound
Date: Tue, 9 May 2006 11:01:18 -0700
Message-ID: <20060509110118.197b9a92@localhost.localdomain>
References: <8dd26e70605091021g526cf9b0raf93c600d2de7129@mail.gmail.com>
	<8dd26e70605091039n2669c4b0ka19d28fa2d502398@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:56997 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750843AbWEISBQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 May 2006 14:01:16 -0400
To: "Angelo P. Castellani" <angelo.castellani+lkml@gmail.com>
In-Reply-To: <8dd26e70605091039n2669c4b0ka19d28fa2d502398@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 9 May 2006 19:39:43 +0200
"Angelo P. Castellani" <angelo.castellani+lkml@gmail.com> wrote:

> I resend the file because I've sent an old (quite identical) copy

Moved discussion over to netdev mailing list..

Could you export symbols in tcp_vegas (and change config dependencies) to
allow code reuse rather than having to copy/paste everything from vegas?

