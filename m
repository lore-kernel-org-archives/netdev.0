From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] iproute: Add ability to save, restore and show the
 interfaces' addresses (resend)
Date: Tue, 11 Sep 2012 09:18:44 -0700
Message-ID: <20120911091844.0868ea9a@nehalam.linuxnetplumber.net>
References: <50121F4D.8090606@parallels.com>
	<50121FB0.6060200@parallels.com>
	<5012211A.4040307@parallels.com>
	<504F5CF4.1040202@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60343 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752838Ab2IKQTN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Sep 2012 12:19:13 -0400
In-Reply-To: <504F5CF4.1040202@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 11 Sep 2012 19:47:00 +0400
Pavel Emelyanov <xemul@parallels.com> wrote:

> This functionality is required by checkpoint-restore project. Since the
> dump and restore for routes is already done in ip tool it's naturally to
> dump and restore addresses in the ip tool as well.
> 
> The implementation logic is the same as for the respective one for routes.
> The magic number digits are taken from the Seattle coordinates.
> 
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

Applied.
