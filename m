From: Daniel Wagner <wagi@monom.org>
Subject: Re: [net-next:master 79/82] net/core/sock.c:1267:3: error: too many
 arguments to function 'sock_update_classid'
Date: Fri, 26 Oct 2012 13:45:35 +0200
Message-ID: <508A77DF.4020508@monom.org>
References: <508a42d2./QGsZgSRCzpLxMff%fengguang.wu@intel.com> <20121026.050720.367513259148701730.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: fengguang.wu@intel.com, daniel.wagner@bmw-carit.de,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hotel311.server4you.de ([85.25.146.15]:53634 "EHLO
	hotel311.server4you.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932333Ab2JZLph (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2012 07:45:37 -0400
In-Reply-To: <20121026.050720.367513259148701730.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26.10.2012 11:07, David Miller wrote:
>
> Fixed thusly:
>
> [PATCH] net: Update args to dummy sock_update_classid().
>
> Only the real implementation got updated.
>
> Signed-off-by: David S. Miller <davem@davemloft.net>

Argh, sorry about that one. Thanks for fixing it.

thanks,
Daniel
