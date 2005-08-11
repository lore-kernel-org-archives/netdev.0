From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] emac: add support for platform-specific unsupported PHY
 features
Date: Thu, 11 Aug 2005 00:03:49 -0400
Message-ID: <42FACE25.5080909@pobox.com>
References: <1123284725.27880.26.camel@rhino.az.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Matt Porter <mporter@kernel.crashing.org>,
        Eugene Surovegin <ebs@ebshome.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Wade Farnsworth <wfarnsworth@mvista.com>
In-Reply-To: <1123284725.27880.26.camel@rhino.az.mvista.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Wade Farnsworth wrote:
> Hello,
> 
> This patch adds support to the ibm_emac driver for platform-specific
> unsupported PHY features.
> 
> The patch attempts to determine the highest speed and duplex when
> autonegotiation is unsupported.
> 
> -Wade Farnsworth
> 
> Signed-off-by: Wade Farnsworth <wfarnsworth@mvista.com>

Can you update this patch RE Eugene's comments?

	Jeff
