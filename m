From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/2] natsemi: Improve diagnostics for DspCfg workaround
Date: Tue, 08 May 2007 01:17:19 -0400
Message-ID: <464007DF.5030102@garzik.org>
References: <20070503093435.7800.38591.stgit@mercator.sirena.org.uk> <20070503093650.7800.45441.stgit@mercator.sirena.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tim Hockin <thockin@hockin.org>,
	=?UTF-8?B?UmFmYcWCIEJpbHNraQ==?= <rafalbilski@interia.pl>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Mark Brown <broonie@sirena.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54334 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967901AbXEHFRZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2007 01:17:25 -0400
In-Reply-To: <20070503093650.7800.45441.stgit@mercator.sirena.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mark Brown wrote:
> The natsemi driver has a workaround for broken hardware which resets itself
> from time to time.  There is a diagnostic message for this workaround but
> it is not printed by default, making the driver behavior more obscure than
> it needs to be.  Make the message be displayed by default.
> 
> Signed-Off-By: Mark Brown <broonie@sirena.org.uk>
> ---
> 
>  drivers/net/natsemi.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)

applied 1-2


