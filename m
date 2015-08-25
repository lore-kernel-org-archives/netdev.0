From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next v2 1/2] Documentation: networking: add a DSA document
Date: Tue, 25 Aug 2015 11:21:16 -0700
Message-ID: <CAE4R7bDeS1+FtSiA-9-f8biDXStDYoOS8NW3CzNTVgVfRRbuvA@mail.gmail.com>
References: <1440524435-8129-1-git-send-email-f.fainelli@gmail.com> <1440524435-8129-2-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Guenter Roeck <linux@roeck-us.net>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f170.google.com ([209.85.214.170]:33816 "EHLO
	mail-ob0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751042AbbHYSVg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 14:21:36 -0400
Received: by obbfr1 with SMTP id fr1so149526233obb.1
        for <netdev@vger.kernel.org>; Tue, 25 Aug 2015 11:21:35 -0700 (PDT)
In-Reply-To: <1440524435-8129-2-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 25, 2015 at 10:40 AM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> Describe how the DSA subsystem works, its design principles,
> limitations, and describe in details how to implement a DSA switch
> driver.
>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
> Changes in v2:
>
> - fixing incomplete sentence in the SWITCHDEV paragraph
> - fix spelling mistakes spotted by Andrew and Vivien
> - add additional feedback from Vivien
> - add a convergence TODO item between SWITCHDEV and DSA
> - misc fixes and improvements

Acked-by: Scott Feldman <sfeldma@gmail.com>
