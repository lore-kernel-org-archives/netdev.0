From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: Comments regarding patch about setting netns for wireless devices
Date: Thu, 18 Sep 2014 09:13:25 -0400
Message-ID: <20140918131324.GA20197@tuxdriver.com>
References: <CAMw6YJ+uhthY83_cBHE20FgqFWdvT5M12AbfgVC7qbyHegh78Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Emmanuel Grumbach <egrumbach@gmail.com>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	johannes@sipsolutions.net
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:35851 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751280AbaIRNPR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2014 09:15:17 -0400
Content-Disposition: inline
In-Reply-To: <CAMw6YJ+uhthY83_cBHE20FgqFWdvT5M12AbfgVC7qbyHegh78Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 18, 2014 at 11:05:11AM +0300, Vadim Kochan wrote:
> Hi All,
> 
> I'd like to get some feedback about the patch:
>     https://patchwork.kernel.org/patch/4890451/
> 
> The idea is that currently Linux wireless device is allowed to change
> the network namespace only by nl80211 API, so RTM_LINK API does
> not work. So I think that it should be possible to change netns
> through the RTM_LINK too as generic way to change netns,
> thats why I tried to solve this in the patch.
> 
> Thanks,

I think Johannes is vacationing right now.  I'm sure he will comment
when he returns.

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
