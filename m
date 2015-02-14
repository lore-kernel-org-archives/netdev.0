From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: Fw: [Bug 93011] New: boilerplate IPVLAN Kconfig
Date: Sat, 14 Feb 2015 10:40:27 -0800
Message-ID: <CAF2d9jgcT4MaCDjmDVTAR8VKZroitM0rt4+PoPWp6ic0E9U98A@mail.gmail.com>
References: <20150209224913.24e48ffa@uryu.home.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:61091 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754149AbbBNSks (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Feb 2015 13:40:48 -0500
Received: by mail-ob0-f175.google.com with SMTP id va2so30651370obc.6
        for <netdev@vger.kernel.org>; Sat, 14 Feb 2015 10:40:48 -0800 (PST)
In-Reply-To: <20150209224913.24e48ffa@uryu.home.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sure I'll send a patch correcting that soon.

On Mon, Feb 9, 2015 at 10:49 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
>
>
> Begin forwarded message:
>
> Date: Mon, 9 Feb 2015 22:06:03 +0000
> From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
> To: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>
> Subject: [Bug 93011] New: boilerplate IPVLAN Kconfig
>
>
> https://bugzilla.kernel.org/show_bug.cgi?id=93011
>
>             Bug ID: 93011
>            Summary: boilerplate IPVLAN Kconfig
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 3.19
>           Hardware: All
>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: low
>           Priority: P1
>          Component: Other
>           Assignee: shemminger@linux-foundation.org
>           Reporter: bugzilla.kernel.bpeb@manchmal.in-ulm.de
>         Regression: No
>
> Hi there,
>
> 3.19 introduced a new option IPVLAN, however the text in
> drivers/net/Kconfig still contains a template:
>
> |      Ipvlan devices can be added using the "ip" command from the
> |      iproute2 package starting with the iproute2-X.Y.ZZ release:
>
> Please update to the appropriate version number.
>
> --
> You are receiving this mail because:
> You are the assignee for the bug.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
