From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: sky bugs in 2.6.22-rc5
Date: Mon, 18 Jun 2007 13:20:21 -0700
Message-ID: <20070618132021.64b08836@localhost.localdomain>
References: <4676E1DD.1060007@trash.net>
	<20070618130414.35801913@localhost.localdomain>
	<4676E77E.4080707@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:33785 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760373AbXFRUU5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2007 16:20:57 -0400
In-Reply-To: <4676E77E.4080707@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 18 Jun 2007 22:13:50 +0200
Patrick McHardy <kaber@trash.net> wrote:

> Stephen Hemminger wrote:
> > Does this fix it?  It was possible for the PHY interrupt to race
> > while bringing link up.
> 
> 
> No, both problems are still present.

What hardware. Could you load with messages max: modprobe sky2 debug=15


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
