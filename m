From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [RFC PATCH 07/16] dsa: Remove dynamic allocate of routing table
Date: Fri, 27 May 2016 14:54:52 -0400
Message-ID: <87eg8nz5z7.fsf@ketchup.mtl.sfl>
References: <1464312050-23023-1-git-send-email-andrew@lunn.ch> <1464312050-23023-8-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	John Crispin <john@phrozen.org>, Bryan.Whitehead@microchip.com,
	Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:34774 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754934AbcE0Syz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 May 2016 14:54:55 -0400
In-Reply-To: <1464312050-23023-8-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

>  	/*
> -	 * An array (with nr_chips elements) of which element [a]
> -	 * indicates which port on this switch should be used to
> -	 * send packets to that are destined for switch a.  Can be
> -	 * NULL if there is only one switch chip.
> +	 * An array of which element [a] indicates which port on this
> +	 * switch should be used to send packets to that are destined
> +	 * for switch a.  Can be NULL if there is only one switch
> +	 * chip.
>  	 */

Please drop the double-space and reformat on 3 lines in the meantime.

Thanks,

        Vivien
