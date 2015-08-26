From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch net-next 5/6] rocker: use new helper to figure out master kind
Date: Wed, 26 Aug 2015 10:56:11 -0700
Message-ID: <CAE4R7bAab3Hpot3zT8USDwH8aqR8L0cvdxYSpireT5w9r+=8Aw@mail.gmail.com>
References: <1440606998-11072-1-git-send-email-jiri@resnulli.us> <1440606998-11072-6-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>, eladr@mellanox.com,
	"simon.horman@netronome.com" <simon.horman@netronome.com>,
	Jiri Pirko <jiri@mellanox.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:35425 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752336AbbHZR4b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 13:56:31 -0400
Received: by obbwr7 with SMTP id wr7so178562595obb.2
        for <netdev@vger.kernel.org>; Wed, 26 Aug 2015 10:56:31 -0700 (PDT)
In-Reply-To: <1440606998-11072-6-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 26, 2015 at 9:36 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> Looking at rtnl kind string is kind of ugly. So use new helpers to do
> this in nicer way.
>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Acked-by: Scott Feldman <sfeldma@gmail.com>
