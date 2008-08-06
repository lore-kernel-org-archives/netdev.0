From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Realtek 8111C transmit timed out
Date: Wed, 6 Aug 2008 20:12:35 +0200
Message-ID: <20080806181235.GA17174@electric-eye.fr.zoreil.com>
References: <2c2a4e250808041812j569f6565s9f4ae54f44bbfbb5@mail.gmail.com> <2c2a4e250808041900id64a2b8h1b7cee3b70960ebc@mail.gmail.com> <2c2a4e250808042042j6c448068v98a6b5e428fa1a7@mail.gmail.com> <20080805214250.GA23226@electric-eye.fr.zoreil.com> <loom.20080806T144054-201@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Indan Zupancic <indan@nul.nu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:43228 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753179AbYHFSOv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2008 14:14:51 -0400
Content-Disposition: inline
In-Reply-To: <loom.20080806T144054-201@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Indan Zupancic <indan@nul.nu> :
[...]
> I'm running a git version just before 2.6.27-rc2 and while the card 
> worked fine in 2.6.26, after a resume from suspend to ram I now get:

You cab try to revert the four (4) r8169.c related patches that went
in between 2.6.26 and 2.6.27-rc1. I doubt it will make a difference
though.

Is a git bisect an option ?

-- 
Ueimor
