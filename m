From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] ethtool: Report MDI-X status for twisted-pair interfaces
Date: Tue, 01 Dec 2009 11:06:56 -0500
Message-ID: <4B153F20.1030407@garzik.org>
References: <1259683230.2831.14.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Chaitanya Lala <clala@riverbed.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:45006 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753699AbZLAQG4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Dec 2009 11:06:56 -0500
In-Reply-To: <1259683230.2831.14.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/01/2009 11:00 AM, Ben Hutchings wrote:
> Based on a patch by Chaitanya Lala<clala@riverbed.com>.
>
> The MDI-X status can be a useful tool for diagnosing network
> connectivity issues.
>
> Signed-off-by: Ben Hutchings<bhutchings@solarflare.com>
> ---
>   ethtool.c |   16 ++++++++++++++++
>   1 files changed, 16 insertions(+), 0 deletions(-)

applied


