From: Brandon Philips <brandon@ifup.org>
Subject: Re: [PATCH RFC] r8169: straighten out overlength frame detection
 (v3)
Date: Tue, 26 Jan 2010 14:07:35 -0800
Message-ID: <20100126220735.GA6577@jenkins.home.ifup.org>
References: <20100110235017.GA8959@electric-eye.fr.zoreil.com>
 <20100110.224504.247142858.davem@davemloft.net>
 <20100112001646.GA7017@electric-eye.fr.zoreil.com>
 <20100111.222400.253153531.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ben@decadent.org.uk, eric.dumazet@gmail.com, nhorman@tuxdriver.com,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f42.google.com ([209.85.160.42]:63373 "EHLO
	mail-pw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752917Ab0AZWHr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jan 2010 17:07:47 -0500
Received: by pwi21 with SMTP id 21so3281022pwi.21
        for <netdev@vger.kernel.org>; Tue, 26 Jan 2010 14:07:45 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20100111.222400.253153531.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22:24 Mon 11 Jan 2010, David Miller wrote:
> From: Francois Romieu <romieu@fr.zoreil.com>
> Date: Tue, 12 Jan 2010 01:16:46 +0100
> 
> > I have spent the evening disrupting the communication. As a challenger
> > one does not even need complete control : send a few random packets and
> > the card goes to neverland. :o/
> > 
> > I'll do some tests limiting the crap at the first packet.
> 
> Thanks for doing this work Francois.

How is the testing going? 

Thanks again,

	Brandon
