From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC] use ktime for packet scheduling
Date: Thu, 08 Mar 2007 18:48:27 +0100
Message-ID: <45F04C6B.9010508@trash.net>
References: <20070222143047.1631b93e@freekitty>	<45E04901.1040505@trash.net> <20070307155936.74bf8abe@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63178 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932264AbXCHRmZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Mar 2007 12:42:25 -0500
In-Reply-To: <20070307155936.74bf8abe@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Here is the lastest version of the netem patch to use hrtimers.
> It is against the current net tree, so it will need adjusting to fit
> with new psched/ktime stuff.

Thanks, I'll add whats still needed to my patches.
