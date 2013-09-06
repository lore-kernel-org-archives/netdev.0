From: Andrew Davidoff <davidoff@qedmf.net>
Subject: Re: Intel igb module command line configuration in kernel sources
Date: Thu, 5 Sep 2013 22:31:51 -0400
Message-ID: <CAJLXCZTu_MmoO+2DC6jHyAfHAODKssUpXMZCwLgtekuf3fttXw@mail.gmail.com>
References: <CAJLXCZRKdz-w8uR3ejzHrBot7OAyVJOWwzA0NszkZL16eFPTbQ@mail.gmail.com>
	<1378391039.3159.1.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:53135 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753240Ab3IFCbw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Sep 2013 22:31:52 -0400
Received: by mail-pb0-f48.google.com with SMTP id ma3so2585759pbc.21
        for <netdev@vger.kernel.org>; Thu, 05 Sep 2013 19:31:51 -0700 (PDT)
In-Reply-To: <1378391039.3159.1.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 5, 2013 at 10:23 AM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
>
> I don't know what you're specifically interested in, but a lot of this
> should be configurable using ethtool.
>
> Module parameters for device-specific settings are deprecated.

Hi Ben,

Thank you for your reply. I am specifically talking about RSS (receive
side scaling). I got word from the e1000-devel list (sorry I didn't
see it first) that, if I understood correctly, indicates ethtool
cannot yet handle RSS for igb, but that it's being worked on.

Thanks again.
Andy


>
> Ben.
>
> --
> Ben Hutchings, Staff Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
