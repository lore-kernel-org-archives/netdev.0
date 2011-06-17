From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v2] net/r8169: update the new parser for the new firmware
Date: Fri, 17 Jun 2011 14:53:00 +0200
Message-ID: <20110617125300.GA2193@electric-eye.fr.zoreil.com>
References: <1308109531-31698-1-git-send-email-hayeswang@realtek.com> <20110616225904.GA2064@electric-eye.fr.zoreil.com> <8AC7DE11560749B895F99EBA7D42AA49@realtek.com.tw> <20110617063948.GA2146@electric-eye.fr.zoreil.com> <1308313364.11457.63.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hayeswang <hayeswang@realtek.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:50152 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758568Ab1FQNFo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 09:05:44 -0400
Content-Disposition: inline
In-Reply-To: <1308313364.11457.63.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings <bhutchings@solarflare.com> :
[...]
> I thought the idea of embedding a version here was to be able to report
> in in get_drvinfo, not to print it on load.

Reporting the version for the new firmware format through ethtool is
currently hacked on.

Do you want the load time version / format messages removed ?

I think they can be of some use - at least temporarily - but I won't mind
removing them now.

-- 
Ueimor
