From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next 1/2] mlx4_en: Add PTP hardware clock
Date: Wed, 18 Dec 2013 09:59:51 +0200
Message-ID: <52B155F7.2070505@mellanox.com>
References: <1387312359-9476-1-git-send-email-shawn.bohrer@gmail.com> <1387312359-9476-2-git-send-email-shawn.bohrer@gmail.com> <CAJZOPZKLSThnWCycVFF1dzoDuks48prUvzSN_us9NYTz82wRsA@mail.gmail.com> <20131217214615.GD8693@sbohrermbp13-local.rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Amir Vadai <amirv@mellanox.com>,
	Richard Cochran <richardcochran@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	<tomk@rgmadvisors.com>, Hadar Hen Zion <hadarh@mellanox.com>,
	Shawn Bohrer <sbohrer@rgmadvisors.com>
To: Shawn Bohrer <shawn.bohrer@gmail.com>,
	Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog108.obsmtp.com ([207.126.144.125]:41097 "EHLO
	eu1sys200aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750961Ab3LRIAD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 03:00:03 -0500
In-Reply-To: <20131217214615.GD8693@sbohrermbp13-local.rgmadvisors.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17/12/2013 23:46, Shawn Bohrer wrote:
> v3: is code identical to v2.  I simply finished testing it with
> linuxptp, cleaned up the commit description a little and sent to davem.
so the problem you saw with V2 is understood && gone with V3?
