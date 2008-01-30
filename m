From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] natsemi: Update locking documentation
Date: Wed, 30 Jan 2008 03:48:55 -0500
Message-ID: <47A039F7.7060204@garzik.org>
References: <1201442291-13668-1-git-send-email-broonie@sirena.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tim Hockin <thockin@hockin.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Mark Brown <broonie@sirena.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:33473 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752463AbYA3Is7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2008 03:48:59 -0500
In-Reply-To: <1201442291-13668-1-git-send-email-broonie@sirena.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mark Brown wrote:
> The documentation regarding synchronisation at the head of the natsemi
> driver was badly bitrotted so replace it with a general statement about
> the techniques used which is less likely to bitrot.
> 
> Also remove the note saying these chips are uncommon - it makes little
> difference but they were used in a number of laptops and at least one mass
> market PCI ethernet card.
> 
> Signed-off-by: Mark Brown <broonie@sirena.org.uk>
> ---
>  drivers/net/natsemi.c |   18 ++----------------
>  1 files changed, 2 insertions(+), 16 deletions(-)

applied


