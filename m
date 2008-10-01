From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: ax25 rose Re: kernel panic linux-2.6.27-rc7
Date: Wed, 1 Oct 2008 05:58:28 +0000
Message-ID: <20081001055828.GA10831@ff.dom.local>
References: <48DF7D51.1010507@free.fr> <20080929123036.GA16954@ff.dom.local> <48E1F417.7080304@free.fr> <20080930101030.GA6290@ff.dom.local> <20080930111733.GB6290@ff.dom.local> <48E29337.2080400@free.fr> <20080930213052.GA6449@ami.dom.local> <48E2ACDE.30406@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Ralf Baechle DL5RB <ralf@linux-mips.org>
To: Bernard Pidoux F6BVP <f6bvp@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:5945 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751458AbYJAF6f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 01:58:35 -0400
Received: by ug-out-1314.google.com with SMTP id k3so739004ugf.37
        for <netdev@vger.kernel.org>; Tue, 30 Sep 2008 22:58:33 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <48E2ACDE.30406@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 01, 2008 at 12:49:02AM +0200, Bernard Pidoux F6BVP wrote:
> Jarek,
>
> With the patch #2, there have been only one reboot after the machine was  
> frozen. I did not notice that was happening for there was no kernel  
> panic message but a frozen display only.
> Then I could only write down partially the values displayed after  
> AX25_DBG: c446c220, c..... 3, 5, 240
> Second number was not 000000 as it is most of the time.
> The machine rebooted after the usual 60 seconds delay and since then  
> there was no kernel panic.
> This is the first time kernel 2.6.27-rc7 does not panic within a minute.
> The system is up since about 20 minutes now with frequent AX25_DBG messages.

Hmm... Since this was intended mainly for debugging something went
wrong. (I expected to get at least one warning.)

>
> I am sorry that I must go to sleep now to be at work early in the morning.
> I will be away from my Linux box for a few days.
> Then we should probably interrupt this interesting bug hunting.
> I will send more results when I am back.

OK, I'll try to look at this in the meantime.

Cheers,
Jarek P.
