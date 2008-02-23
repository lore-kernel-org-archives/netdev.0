From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH] [PS3] gelic wireless driver needs MAC80211 support
Date: Sat, 23 Feb 2008 21:19:42 +0100
Message-ID: <200802232119.43051.IvDoorn@gmail.com>
References: <20080223193517.GA6704@Chamillionaire.breakpoint.cc> <200802232044.59887.IvDoorn@gmail.com> <20080223201535.GC7135@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Masakazu Mokuno <mokuno@sm.sony.co.jp>, jgarzik@pobox.com,
	netdev@vger.kernel.org
To: Sebastian Siewior <netdev@ml.breakpoint.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from el-out-1112.google.com ([209.85.162.181]:1917 "EHLO
	el-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754378AbYBWUUF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Feb 2008 15:20:05 -0500
Received: by el-out-1112.google.com with SMTP id v27so734139ele.23
        for <netdev@vger.kernel.org>; Sat, 23 Feb 2008 12:20:02 -0800 (PST)
In-Reply-To: <20080223201535.GC7135@Chamillionaire.breakpoint.cc>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 23 February 2008, Sebastian Siewior wrote:
> * Ivo van Doorn | 2008-02-23 20:44:59 [+0100]:
> 
> >Is there any particular reason why this driver is in drivers/net instead
> >of drivers/net/wireless (along with all other wireless drivers?
> 
> My understanding is/was that the wireless device and the eth device are
> exposed by the hypervisor to the system and they share ressources.

Ah ok, makes sense. :)

Thanks.

Ivo
