From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Regression: non-working WOL with r8169
Date: Fri, 7 Oct 2011 23:42:00 +0200
Message-ID: <20111007214200.GA28365@electric-eye.fr.zoreil.com>
References: <20111007221906.810698ba9bf825566a2478bb@gmx.de> <20111007210017.GA27820@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hayeswang@realtek.com, netdev@vger.kernel.org
To: Marc Ballarin <ballarin.marc@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:39522 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752843Ab1JGVoL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2011 17:44:11 -0400
Content-Disposition: inline
In-Reply-To: <20111007210017.GA27820@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu <romieu@fr.zoreil.com> :
> Marc Ballarin <ballarin.marc@gmx.de> :
> [...]
> > Feel free to ask for any further information.
> 
> Did your testing start after 106633897e086e1b47126996aac1a427eb80eb1b ?

I guess the answer will be "yes" or it will not make a difference anyway.

Can you tell if CONFIG_PM is set and how the computer was shutdown / halted ?

-- 
Ueimor
