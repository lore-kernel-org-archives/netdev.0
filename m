From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] vlan_dev: VLAN 0 should be treated as "no vlan tag"
 (802.1p packet)
Date: Mon, 14 Jun 2010 18:02:25 +0100
Message-ID: <1276534945.2074.11.camel@achroite.uk.solarflarecom.com>
References: <c25bca517739ada31d698235c3a4d045@dondevamos.com>
	 <1276466190.14011.223.camel@localhost>
	 <5c6d1ac43fd8ad25661ebfba57c02174@dondevamos.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Pedro Garcia <pedro.netdev@dondevamos.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:23369 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755662Ab0FNRC3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jun 2010 13:02:29 -0400
In-Reply-To: <5c6d1ac43fd8ad25661ebfba57c02174@dondevamos.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-06-14 at 18:49 +0200, Pedro Garcia wrote:
> On Sun, 13 Jun 2010 22:56:30 +0100, Ben Hutchings
> <bhutchings@solarflare.com> wrote:
> > I have no particular opinion on this change, but you need to read and
> > follow Documentation/SubmittingPatches.
> > 
> > Ben.
> 
> Sorry, first kernel patch, and I did not know about it. I resubmit with
> the correct style / format:
[...]

Sorry, no you haven't.

- Networking changes go through David Miller's net-next-2.6 tree so you
need to use that as the baseline, not 2.6.26
- Patches should be applicable with -p1, not -p0 (so if you use diff,
you should run it from one directory level up)
- The patch was word-wrapped

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

