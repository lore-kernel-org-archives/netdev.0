From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/4] sfc: I2C adapter initialisation fixes
Date: Tue, 22 Jul 2008 19:44:31 -0400
Message-ID: <488670DF.6030109@pobox.com>
References: <20080718175911.GF10471@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52557 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751802AbYGVXoe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jul 2008 19:44:34 -0400
In-Reply-To: <20080718175911.GF10471@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> As recommended by Jean Delvare:
> - Increase timeout to 50 ms
> - Leave adapter class clear so that unwanted drivers do not probe our bus
> - Use strlcpy() for name initialisation
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
> Jeff,
> 
> These are exactly the differences between net-2.6 and the version of sfc I
> intended to submit to you before today.  If this doesn't apply then I'm
> confused as to what you have.

applied patches 1, 2, 4


