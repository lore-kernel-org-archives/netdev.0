From: "Michal Piotrowski" <michal.k.k.piotrowski@gmail.com>
Subject: Re: PROBLEM: 2.6.23-rc "NETDEV WATCHDOG: eth0: transmit timed out"
Date: Mon, 3 Sep 2007 00:15:46 +0200
Message-ID: <6bffcb0e0709021515v586f078cjce04f877e2f27aa2@mail.gmail.com>
References: <be1b757c0708130435y689b9dd8raf9ac9f9c0fcc976@mail.gmail.com>
	 <20070813165821.GA19356@electric-eye.fr.zoreil.com>
	 <be1b757c0708131027v5c57822as2d9bd3190fd19b71@mail.gmail.com>
	 <20070814070901.GA14693@electric-eye.fr.zoreil.com>
	 <be1b757c0708141425qd887581n3922702b84a21758@mail.gmail.com>
	 <20070814224629.GB3495@electric-eye.fr.zoreil.com>
	 <20070816141122.GA6625@electric-eye.fr.zoreil.com>
	 <be1b757c0709011224tafebaaby697d03ab5377e20f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Francois Romieu" <romieu@fr.zoreil.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Karl Meyer" <adhocrocker@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.180]:35738 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754517AbXIBWPu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Sep 2007 18:15:50 -0400
Received: by wa-out-1112.google.com with SMTP id v27so1681210wah
        for <netdev@vger.kernel.org>; Sun, 02 Sep 2007 15:15:50 -0700 (PDT)
In-Reply-To: <be1b757c0709011224tafebaaby697d03ab5377e20f@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On 01/09/07, Karl Meyer <adhocrocker@gmail.com> wrote:
> This is what happened today:
>
> Sep  1 21:08:01 frege NETDEV WATCHDOG: eth0: transmit timed out
> frege ~ # uname -r
> 2.6.22.5-cfs-v20.5

Can you reproduce this on 2.6.22 (not 2.6.22.x - it might be a -stable
regression)?

Regards,
Michal

-- 
LOG
http://www.stardust.webpages.pl/log/
