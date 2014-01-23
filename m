From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH net-next v2 4/4] net: phy: remove unneeded parenthesis
Date: Thu, 23 Jan 2014 21:39:01 -0200
Message-ID: <CAOMZO5DpxzM8kOwfo3_LYGRc3=JL5H4FuRktdY2JxMwBgby7Yw@mail.gmail.com>
References: <1390508269-28769-1-git-send-email-f.fainelli@gmail.com>
	<1390508269-28769-5-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Joe Perches <joe@perches.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f53.google.com ([209.85.212.53]:40003 "EHLO
	mail-vb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754363AbaAWXjD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 18:39:03 -0500
Received: by mail-vb0-f53.google.com with SMTP id p17so1442927vbe.40
        for <netdev@vger.kernel.org>; Thu, 23 Jan 2014 15:39:01 -0800 (PST)
In-Reply-To: <1390508269-28769-5-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 23, 2014 at 6:17 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> Our if/else statement in phy_print_status() is only comprised of one
> line for each, remove the parenthesis.

Your patch removes the braces, not the parenthesis ;-)

Regards,

Fabio Estevam
