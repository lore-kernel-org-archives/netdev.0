From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6.10-rc1] remove NET_HW_FLOWCONTROL
Date: Mon, 25 Oct 2004 16:21:59 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <417D6067.3010102@pobox.com>
References: <20041025202042.GA4930@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@davemloft.net>,
        jamal <hadi@cyberus.ca>
Return-path: <netdev-bounce@oss.sgi.com>
To: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <20041025202042.GA4930@infradead.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Arjan van de Ven wrote:
> CONFIG_NET_HW_FLOWCONTROL is entirely unused now, and superceded by NAPI in
> practice, so remove the dead code

Ok with me.  Jamal?

	Jeff
