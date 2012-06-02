From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Network hangs on current git kernel
Date: Sat, 02 Jun 2012 13:15:03 +0200
Message-ID: <1338635703.2760.1696.camel@edumazet-glaptop>
References: <20120602082503.GC329@x4>
	 <1338630610.2760.1695.camel@edumazet-glaptop>
	 <20120602105747.GB28769@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Markus Trippelsdorf <markus@trippelsdorf.de>,
	netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:33174 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966565Ab2FBLPJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jun 2012 07:15:09 -0400
Received: by weyu7 with SMTP id u7so1889147wey.19
        for <netdev@vger.kernel.org>; Sat, 02 Jun 2012 04:15:08 -0700 (PDT)
In-Reply-To: <20120602105747.GB28769@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-06-02 at 12:57 +0200, Francois Romieu wrote:
> Eric Dumazet <eric.dumazet@gmail.com> :
> > On Sat, 2012-06-02 at 10:25 +0200, Markus Trippelsdorf wrote:
> [hang]
> > Maybe tell us what NIC it is, that sort of things...
> 
> As well as 'ip -s link' and complete dmesg from boot.
> Kernel .config may be.

yes, and "netstat -s" is always useful
