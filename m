From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: 2.6.21.5+1small patch: not blocking
Date: Fri, 29 Jun 2007 21:22:03 +0200
Message-ID: <20070629192203.GA1227@electric-eye.fr.zoreil.com>
References: <4683F923.80508@bcsoft.de> <20070628213050.GB4233@electric-eye.fr.zoreil.com> <4684F898.80204@bcsoft.de> <468528F8.8050806@bcsoft.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev list <netdev@vger.kernel.org>
To: Jens Stroebel <drifter@bcsoft.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:34614 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752355AbXF2TZp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jun 2007 15:25:45 -0400
Content-Disposition: inline
In-Reply-To: <468528F8.8050806@bcsoft.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jens Stroebel <drifter@bcsoft.de> :
[...]
> It seems like the patch is able to change things in a way which makes
> the machine lock up hard. Pity that, looked so promising at first...

As a 8168 user, you should really apply the serie I sent yesterday before
anything else. Then you can try again this patch.

Can you publish your .config somewhere ?

-- 
Ueimor
