From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch net-next v4 1/7] switchdev: introduce switchdev workqueue
Date: Mon, 12 Oct 2015 20:01:27 -0700
Message-ID: <CAE4R7bAbWfeakZksBCv4ePDC7FwA-DYjJfRNRHF4L30-K=jeJw@mail.gmail.com>
References: <1444672467-20621-1-git-send-email-jiri@resnulli.us> <1444672467-20621-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>,
	Elad Raz <eladr@mellanox.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	john fastabend <john.fastabend@gmail.com>,
	David Laight <David.Laight@aculab.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:34098 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751009AbbJMDBr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 23:01:47 -0400
Received: by obbda8 with SMTP id da8so3661605obb.1
        for <netdev@vger.kernel.org>; Mon, 12 Oct 2015 20:01:47 -0700 (PDT)
In-Reply-To: <1444672467-20621-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 12, 2015 at 10:54 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> This is going to be used for deferred operations.
>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Acked-by: Scott Feldman <sfeldma@gmail.com>
