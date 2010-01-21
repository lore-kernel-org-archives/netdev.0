From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] iproute2: avoid using bashisms in configure script.
Date: Thu, 21 Jan 2010 10:09:42 -0800
Message-ID: <20100121100942.61fe9b06@nehalam>
References: <20100101222030.GA12149@amd64.fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andreas Henriksson <andreas@fatal.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48496 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754610Ab0AUSJt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jan 2010 13:09:49 -0500
In-Reply-To: <20100101222030.GA12149@amd64.fatal.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 1 Jan 2010 23:20:30 +0100
Andreas Henriksson <andreas@fatal.se> wrote:

> "function foo" should be "foo()" to work when sh is not bash.
> 
> Signed-off-by: Andreas Henriksson <andreas@fatal.se>
> ---

applied, 
