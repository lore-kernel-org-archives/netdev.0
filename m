From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 04/27] Documentation/networking/igbvf.txt: Update
 documentation
Date: Sat, 11 Dec 2010 06:34:09 +0000
Message-ID: <1292049249.3136.28.camel@localhost>
References: <1292048241-22026-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1292048241-22026-5-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	bphilips@novell.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:24490 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752261Ab0LKGeN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Dec 2010 01:34:13 -0500
In-Reply-To: <1292048241-22026-5-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-12-10 at 22:16 -0800, Jeff Kirsher wrote:
> Update Intel Wired LAN igbvf documentation.
> 
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  Documentation/networking/igbvf.txt |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletions(-)
> 
> diff --git a/Documentation/networking/igbvf.txt b/Documentation/networking/igbvf.txt
> index 0560281..694817b 100644
> --- a/Documentation/networking/igbvf.txt
> +++ b/Documentation/networking/igbvf.txt
> @@ -58,7 +58,9 @@ Additional Configurations
>    Ethtool
>    -------
>    The driver utilizes the ethtool interface for driver configuration and
> -  diagnostics, as well as displaying statistical information.
> +  diagnostics, as well as displaying statistical information.  Ethtool
> +  version 3.0 or later is required for this functionality, although we
> +  strongly recommend downloading the latest version at:
>  
>    http://sourceforge.net/projects/gkernel.

Do I have to point out every instance of this URL individually?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

