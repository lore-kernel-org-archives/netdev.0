From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] Fix error decoding router advertisements netlink
 messages
Date: Wed, 20 Jul 2011 16:04:22 -0700
Message-ID: <20110720160422.18a81e19@nehalam.ftrdhcpuser.net>
References: <1311151281-25479-1-git-send-email-andreas@fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Christoph Biedl <debian.axhn@manchmal.in-ulm.de>
To: Andreas Henriksson <andreas@fatal.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51478 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751545Ab1GTXET (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 19:04:19 -0400
In-Reply-To: <1311151281-25479-1-git-send-email-andreas@fatal.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 20 Jul 2011 10:41:21 +0200
Andreas Henriksson <andreas@fatal.se> wrote:

> From: Christoph Biedl <debian.axhn@manchmal.in-ulm.de>
> 
> The "ip monitor" command does properly decode the "preferred" and
> "valid" lifetime records in router advertisements from netlink
> messages.
> 
> For more details see http://bugs.debian.org/634170
> 
> Signed-off-by: Andreas Henriksson <andreas@fatal.se>

Applied
