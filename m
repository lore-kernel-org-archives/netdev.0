From: Glynn Clements <glynn.clements@virgin.net>
Subject: Re: making routes permanent
Date: Mon, 29 Apr 2002 04:01:12 +0100
Sender: linux-net-owner@vger.kernel.org
Message-ID: <15564.46968.25439.874672@cerise.nosuchdomain.co.uk>
References: <15564.28280.676012.601803@cerise.nosuchdomain.co.uk>
	<20020429020848.54267.qmail@web21102.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Vinod <geekvinod@yahoo.com>
In-Reply-To: <20020429020848.54267.qmail@web21102.mail.yahoo.com>
List-Id: netdev.vger.kernel.org


Vinod wrote:

> where should i put the command 
> any net 10.0.3.0 255.255.255.0 gw 10.0.0.10
> u suggested?

In /etc/sysconfig/static-routes.

-- 
Glynn Clements <glynn.clements@virgin.net>
