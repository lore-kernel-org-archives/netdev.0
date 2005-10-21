From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch] forcedeth: add support for interrupt mitigation
Date: Fri, 21 Oct 2005 17:07:13 -0400
Message-ID: <43595881.3030809@pobox.com>
References: <43592FE5.20106@colorfullife.com> <20051021202908.GA18966@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Manfred Spraul <manfred@colorfullife.com>, Netdev <netdev@oss.sgi.com>,
        Ayaz Abdulla <AAbdulla@nvidia.com>,
        "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20051021202908.GA18966@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

FWIW the ideal is to implement both NAPI -and- hardware interrupt 
mitigation.

	Jeff
