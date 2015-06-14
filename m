From: Rami Rosen <roszenrami@gmail.com>
Subject: Re: [PATCH net-next] bridge: del external_learned fdbs from device on
 flush or ageout
Date: Mon, 15 Jun 2015 01:14:15 +0300
Message-ID: <CAKoUArkKtWyRyDHc2R03xk5TixMKOG+66_prPrycs2rU0wYpJA@mail.gmail.com>
References: <1434306791-43364-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	roopa@cumulusnetworks.com, john.r.fastabend@intel.com,
	andrew@lunn.ch, f.fainelli@gmail.com, linux@roeck-us.net,
	stephen@networkplumber.org
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f181.google.com ([209.85.220.181]:34872 "EHLO
	mail-qk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752143AbbFNWOQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Jun 2015 18:14:16 -0400
Received: by qkhq76 with SMTP id q76so45044841qkh.2
        for <netdev@vger.kernel.org>; Sun, 14 Jun 2015 15:14:15 -0700 (PDT)
In-Reply-To: <1434306791-43364-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

You mention bridge doing ageing vs. device doing
ageing. AFAIK, there is no way to prevent a bridge from doing aging by
a sysfs entry. Do you think that preventing bridge aging via sysfs is
needed?

Regards,
Rami Rosen
