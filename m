From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch net-next 1/2] switchdev: s/netdev_switch_/switchdev_/
Date: Mon, 13 Apr 2015 07:48:51 -0700
Message-ID: <CAE4R7bBndOxs6Gt6ZV8WxNfmW8_GU=-vE4Wp=bCHsAq_rSa1JA@mail.gmail.com>
References: <1428934475-15349-1-git-send-email-jiri@resnulli.us>
	<1428934475-15349-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f178.google.com ([209.85.220.178]:35651 "EHLO
	mail-qk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754230AbbDMOsw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 10:48:52 -0400
Received: by qkhg7 with SMTP id g7so183799690qkh.2
        for <netdev@vger.kernel.org>; Mon, 13 Apr 2015 07:48:51 -0700 (PDT)
In-Reply-To: <1428934475-15349-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 13, 2015 at 7:14 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> Turned out that "switchdev" sticks. So just unify all releated terms to
> use this prefix.
>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

NACK.  I'm right in the middle of a large patchset which touches all
of these files in all of those places and a rename before mine will
create a git merge nightmare.  Please wait to post any rename patches
until after my set goes in.

-scott
