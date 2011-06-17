From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v2] net/r8169: update the new parser for the new
 firmware
Date: Fri, 17 Jun 2011 15:50:19 +0100
Message-ID: <1308322219.2831.1.camel@bwh-desktop>
References: <1308109531-31698-1-git-send-email-hayeswang@realtek.com>
	 <20110616225904.GA2064@electric-eye.fr.zoreil.com>
	 <8AC7DE11560749B895F99EBA7D42AA49@realtek.com.tw>
	 <20110617063948.GA2146@electric-eye.fr.zoreil.com>
	 <1308313364.11457.63.camel@localhost>
	 <20110617125300.GA2193@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: hayeswang <hayeswang@realtek.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:28576 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759245Ab1FQOuX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 10:50:23 -0400
In-Reply-To: <20110617125300.GA2193@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-06-17 at 14:53 +0200, Francois Romieu wrote:
> Ben Hutchings <bhutchings@solarflare.com> :
> [...]
> > I thought the idea of embedding a version here was to be able to report
> > in in get_drvinfo, not to print it on load.
> 
> Reporting the version for the new firmware format through ethtool is
> currently hacked on.
> 
> Do you want the load time version / format messages removed ?
>
> I think they can be of some use - at least temporarily - but I won't mind
> removing them now.

I don't care one way or the other.  But it's more important to report
the version through get_drvinfo.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

