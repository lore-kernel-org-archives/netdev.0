From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/2] ethtool: Show short message for syntax error
Date: Fri, 06 Mar 2009 05:59:42 -0500
Message-ID: <49B1021E.5030309@pobox.com>
References: <20081127041112.GK15344@decadentplace.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:34462 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751038AbZCFK7t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Mar 2009 05:59:49 -0500
In-Reply-To: <20081127041112.GK15344@decadentplace.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> In case of a syntax error it's likely to be more helpful to just say
> that rather than showing the entire usage information, which is now
> very long.
> 
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> ---
> This change has been in Debian for some years, made in response to
> bug report http://bugs.debian.org/256249

applied


