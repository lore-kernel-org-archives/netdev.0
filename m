From: Neil Armstrong <narmstrong@baylibre.com>
Subject: Re: [PATCH v2 0/6] net: dsa: mv88e6060: cleanup and fix setup
Date: Thu, 12 Nov 2015 15:16:45 +0100
Message-ID: <56449F4D.7060109@baylibre.com>
References: <5642126D.9040105@baylibre.com> <20151110161404.GC23891@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:33201 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753193AbbKLOQ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Nov 2015 09:16:56 -0500
Received: by wmec201 with SMTP id c201so35136098wme.0
        for <netdev@vger.kernel.org>; Thu, 12 Nov 2015 06:16:55 -0800 (PST)
In-Reply-To: <20151110161404.GC23891@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/10/2015 05:14 PM, Andrew Lunn wrote:
> On Tue, Nov 10, 2015 at 04:51:09PM +0100, Neil Armstrong wrote:
>> This patchset introduces some fixes and a registers addressing cleanup for
>> the mv88e6060 DSA driver.
> 
> Hi Neil
> 
> It is normal for netdev to put into the email subject of patches which
> tree these patches are for. "net" would be the latest -rcX and is for
> fixes only. "net-next" would be for new work aimed at the next merge
> window.
> 
> So long as Dave does not complain, leave them as they are now. But
> please try to follow this for your next patches.
> 
> Thanks
>        Andrew
> 
Andrew,

Understood, I'll be careful for the next submissions.

Thanks,
Neil
