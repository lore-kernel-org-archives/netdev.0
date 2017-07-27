From: Phil Sutter <phil@nwl.cc>
Subject: Re: TC-pedit man page examples error
Date: Thu, 27 Jul 2017 08:08:08 +0200
Message-ID: <20170727060808.GK2235@orbyte.nwl.cc>
References: <CAEPezq43wKM1ivHAUu6pFoGqz9+nCJ1FT9xQV702S_BCQvropA@mail.gmail.com>
 <20170726084338.GH2235@orbyte.nwl.cc>
 <CAEPezq4Emc=D7zspWqLOq=80WGUjVdfT0xkqoJ1XQPXqaL3w6w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Tyler Bautista <tylerbautista@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:49961 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751042AbdG0GIJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Jul 2017 02:08:09 -0400
Content-Disposition: inline
In-Reply-To: <CAEPezq4Emc=D7zspWqLOq=80WGUjVdfT0xkqoJ1XQPXqaL3w6w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tyler,

On Wed, Jul 26, 2017 at 09:47:51AM -0700, Tyler Bautista wrote:
> Thank you for taking my message. I have gotten a solution working so
> feel free to ignore the rest of this email. By vanilla iproute2 do you
> mean the latest package through the yum or apt repository? All I can
> tell you is that in the example I gave the iproute2 package was the
> latest one through the RHEL 7 yum repository.

'Vanilla' is a widely used term[1], I meant using latest iproute2 from
upstream[2], ideally from Git. You have to report problems with RHEL
packages in Red Hat bugzilla[3].

Cheers, Phil


[1] https://en.wikipedia.org/wiki/Vanilla_software
[2] https://wiki.linuxfoundation.org/networking/iproute2
[3] https://bugzilla.redhat.com/
