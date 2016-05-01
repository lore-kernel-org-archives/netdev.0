From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: sfc: Please add rss_cpus=hyperthreads support
Date: Sat, 30 Apr 2016 19:27:58 -0700
Message-ID: <CALCETrUDCB0M8vYBwgjjOoheD6keeAwRn7RWYPQusMjkyGBZ1g@mail.gmail.com>
References: <CALCETrWpJMT-SfKKhjRfeNRrXS6C6+SUuzOCuSYwMZbMCqB+tA@mail.gmail.com>
 <5548CA3D.7010408@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Shradha Shah <sshah@solarflare.com>,
	Edward Cree <ecree@solarflare.com>,
	Network Development <netdev@vger.kernel.org>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>
To: Robert Stonehouse <rstonehouse@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:35294 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751651AbcEAC2S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Apr 2016 22:28:18 -0400
Received: by mail-ob0-f174.google.com with SMTP id n10so64662168obb.2
        for <netdev@vger.kernel.org>; Sat, 30 Apr 2016 19:28:18 -0700 (PDT)
In-Reply-To: <5548CA3D.7010408@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 5, 2015 at 6:48 AM, Robert Stonehouse
<rstonehouse@solarflare.com> wrote:
> On 02/05/15 01:03, Andy Lutomirski wrote:
>>
>> Can you please port the rss_cpus=hyperthreads feature from the
>> OpenOnload driver to the upstream driver?  The fact that sticking:
>>
>> options sfc rss_cpus=hyperthreads
>>
>> into modprobe.conf causes sfc to fail to load when OpenOnload isn't
>> installed is incredibly annoying, and the option is genuinely useful.
>
>
> Sure; I will make sure that happens soon.
> I can see how that would be annoying.

Ping?

Thanks,
Andy
