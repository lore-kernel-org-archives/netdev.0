From: Robert Stonehouse <rstonehouse@solarflare.com>
Subject: Re: sfc: Please add rss_cpus=hyperthreads support
Date: Tue, 5 May 2015 14:48:45 +0100
Message-ID: <5548CA3D.7010408@solarflare.com>
References: <CALCETrWpJMT-SfKKhjRfeNRrXS6C6+SUuzOCuSYwMZbMCqB+tA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
To: Andy Lutomirski <luto@amacapital.net>,
	Shradha Shah <sshah@solarflare.com>,
	Edward Cree <ecree@solarflare.com>,
	"Network Development" <netdev@vger.kernel.org>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:64910 "EHLO
	nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S2992488AbbEEN5o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 09:57:44 -0400
In-Reply-To: <CALCETrWpJMT-SfKKhjRfeNRrXS6C6+SUuzOCuSYwMZbMCqB+tA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/05/15 01:03, Andy Lutomirski wrote:
> Can you please port the rss_cpus=hyperthreads feature from the
> OpenOnload driver to the upstream driver?  The fact that sticking:
>
> options sfc rss_cpus=hyperthreads
>
> into modprobe.conf causes sfc to fail to load when OpenOnload isn't
> installed is incredibly annoying, and the option is genuinely useful.

Sure; I will make sure that happens soon.
I can see how that would be annoying.

Thanks for the suggestion.
Rob
