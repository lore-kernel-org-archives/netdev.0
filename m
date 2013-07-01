From: Richard Weinberger <richard@nod.at>
Subject: Re: [PATCH] drivers/ptp/Kconfig: add "depends on HAS_IOMEM" for 'PTP_1588_CLOCK_PCH'
Date: Mon, 01 Jul 2013 13:12:47 +0200
Message-ID: <51D1642F.9010303@nod.at>
References: <51CB8CB7.6010006@asianux.com> <20130628.212311.1348427834856668120.davem@davemloft.net> <51D0DCB5.5060106@asianux.com> <51D11661.7040604@nod.at> <51D11D14.8000706@asianux.com> <51D122F0.1000204@nod.at> <51D12545.4000108@asianux.com> <CAMuHMdXnO8-9riLcFLQfMoWJRgy7gtQJdKkHZNR0D5eaM4=oxQ@mail.gmail.com> <51D1341E.6090908@asianux.com> <CAMuHMdVkVQvo0vAyHc8Cny7eCtWwcZGBWqK3dBS+ZEwNzhtHjw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Chen Gang <gang.chen@asianux.com>,
	David Miller <davem@davemloft.net>,
	Richard Cochran <richardcochran@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from b.ns.miles-group.at ([95.130.255.144]:1660 "EHLO radon.swed.at"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753234Ab3GALMu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Jul 2013 07:12:50 -0400
In-Reply-To: <CAMuHMdVkVQvo0vAyHc8Cny7eCtWwcZGBWqK3dBS+ZEwNzhtHjw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 01.07.2013 09:56, schrieb Geert Uytterhoeven:
> If we follow your reasoning, we can add dummy variants of all hardware support
> that lives in arch/*/include/asm to asm-generic, so everything would compile
> for all platforms. But that's now what we want.

I hope you meant *not* want?

Thanks,
//richard
