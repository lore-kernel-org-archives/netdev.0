From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch net-next v2 5/6] switchdev: bring back switchdev_obj and
 use it as a generic object param
Date: Thu, 1 Oct 2015 08:53:37 -0700
Message-ID: <CAE4R7bAXGhXya8nMi4H63ZSNAv5V8Lqpa4SL4RXujkYhU7+WfQ@mail.gmail.com>
References: <1443690226-29833-1-git-send-email-jiri@resnulli.us> <1443690226-29833-6-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>, eladr@mellanox.com,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	"andrew@lunn.ch" <andrew@lunn.ch>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:35205 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751194AbbJAPx5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2015 11:53:57 -0400
Received: by obbzf10 with SMTP id zf10so61157201obb.2
        for <netdev@vger.kernel.org>; Thu, 01 Oct 2015 08:53:56 -0700 (PDT)
In-Reply-To: <1443690226-29833-6-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 1, 2015 at 2:03 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> Replace "void *obj" with a generic structure. Introduce couple of
> helpers along that.
>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
> v1->v2:
> * align object structure getter name with structure name as suggested by
>   Vivien
> ---

Acked-by: Scott Feldman <sfeldma@gmail.com>
