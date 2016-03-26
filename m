From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH 1/2] net: dsa: mv88e6xxx: Introduce _mv88e6xxx_phy_page_{read,write}
Date: Sat, 26 Mar 2016 16:15:25 -0400
Message-ID: <87shzddmhu.fsf@ketchup.mtl.sfl>
References: <1458951004-27424-1-git-send-email-patrick@puiterwijk.org> <56F5E9D1.9030909@roeck-us.net> <CAJweMdYoiA5mwHW3kSQOY0y46=GuLhnBor7mS3kXo9K3FGqW4g@mail.gmail.com> <56F5F71B.3090703@roeck-us.net> <87vb49gkdo.fsf@ketchup.mtl.sfl> <20160326191844.GA5547@lunn.ch> <87lh55hvyb.fsf@ketchup.mtl.sfl> <20160326194637.GB5547@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Guenter Roeck <linux@roeck-us.net>,
	Patrick Uiterwijk <patrick@puiterwijk.org>,
	davem@davemloft.net, linux@arm.linux.org.uk,
	netdev@vger.kernel.org, Dennis Gilmore <dennis@ausil.us>,
	Peter Robinson <pbrobinson@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:46910 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753615AbcCZUPa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Mar 2016 16:15:30 -0400
In-Reply-To: <20160326194637.GB5547@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Lunn <andrew@lunn.ch> writes:

>> page_0 is fine. What about an even more explicit "clear_page_0" label?
>
> We are not clearing anything. We are changing to page 0. So
>
> restore_page_0?

+1
