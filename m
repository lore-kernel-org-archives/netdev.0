From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 1/2] net: dsa: mv88e6xxx: Introduce
 _mv88e6xxx_phy_page_{read,write}
Date: Sat, 26 Mar 2016 20:18:44 +0100
Message-ID: <20160326191844.GA5547@lunn.ch>
References: <1458951004-27424-1-git-send-email-patrick@puiterwijk.org>
 <56F5E9D1.9030909@roeck-us.net>
 <CAJweMdYoiA5mwHW3kSQOY0y46=GuLhnBor7mS3kXo9K3FGqW4g@mail.gmail.com>
 <56F5F71B.3090703@roeck-us.net>
 <87vb49gkdo.fsf@ketchup.mtl.sfl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Guenter Roeck <linux@roeck-us.net>,
	Patrick Uiterwijk <patrick@puiterwijk.org>,
	davem@davemloft.net, linux@arm.linux.org.uk,
	netdev@vger.kernel.org, Dennis Gilmore <dennis@ausil.us>,
	Peter Robinson <pbrobinson@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:57119 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753339AbcCZTTJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Mar 2016 15:19:09 -0400
Content-Disposition: inline
In-Reply-To: <87vb49gkdo.fsf@ketchup.mtl.sfl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> "error" definitely doesn't make sense, especially in case of success. If
> one has a better suggestion that "clear" for the label, I don't really
> mind.

Hi Vivien, Guenter

page_0 ?

      Andrew
