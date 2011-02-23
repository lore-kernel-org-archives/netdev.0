From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH v2] ethtool : Add option -L | --set-common to set common flags.
Date: Tue, 22 Feb 2011 16:41:48 -0800
Message-ID: <AANLkTimDeTcBn3r=VQ1Ejm=WuN7ZSjeZrhyWCT3cWrkC@mail.gmail.com>
References: <1294963892-11997-1-git-send-email-maheshb@google.com>
	<1295390237-27381-1-git-send-email-maheshb@google.com>
	<1298304057.2608.39.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Laurent Chavey <chavey@google.com>,
	netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:12178 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751517Ab1BWAlv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Feb 2011 19:41:51 -0500
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id p1N0foKc013757
	for <netdev@vger.kernel.org>; Tue, 22 Feb 2011 16:41:50 -0800
Received: from bwz8 (bwz8.prod.google.com [10.188.26.8])
	by hpaq1.eem.corp.google.com with ESMTP id p1N0fLeS009472
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 22 Feb 2011 16:41:49 -0800
Received: by bwz8 with SMTP id 8so2630373bwz.35
        for <netdev@vger.kernel.org>; Tue, 22 Feb 2011 16:41:49 -0800 (PST)
In-Reply-To: <1298304057.2608.39.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

That makes sense! The corresponding kernel patch -

http://patchwork.ozlabs.org/patch/77815/

is in RFC state. So what does that state mean?

Thanks,
--mahesh..

On Mon, Feb 21, 2011 at 8:00 AM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
>
> On Tue, 2011-01-18 at 14:37 -0800, Mahesh Bandewar wrote:
> > This patch adds -L | --set-common option to add / remove common flags which
> > includes loopback flag. The -l | --show-common displays the current values
> > for these common flags.
> [...]
>
> I haven't forgotten this, but I won't apply it until the corresponding
> kernel change is applied.
>
> Ben.
>
> --
> Ben Hutchings, Senior Software Engineer, Solarflare Communications
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
>
