From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] emac: filter illegal frame sizes
Date: Sat, 19 Feb 2005 03:48:36 -0500
Message-ID: <4216FD64.9020509@pobox.com>
References: <20050218101245.D11439@cox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linuxppc-embedded@ozlabs.org
To: Matt Porter <mporter@kernel.crashing.org>
In-Reply-To: <20050218101245.D11439@cox.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Matt Porter wrote:
> Fix to drop frames that are too large for the current MTU.

What is this fixing?

You should be passing all frames up to the software stack.

	Jeff
