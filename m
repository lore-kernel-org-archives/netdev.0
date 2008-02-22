From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [PATCH 03/08] [TIPC]: Eliminate "sparse" warning in socket code
Date: Fri, 22 Feb 2008 21:04:25 +0100
Message-ID: <20080222200425.GC7154@uranus.ravnborg.org>
References: <AF1602CB2550CE4381C0C75118A7856B0246C891@ala-mail02.corp.ad.wrs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "Stephens, Allan" <allan.stephens@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pasmtpb.tele.dk ([80.160.77.98]:58866 "EHLO pasmtpB.tele.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933818AbYBVUEN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Feb 2008 15:04:13 -0500
Content-Disposition: inline
In-Reply-To: <AF1602CB2550CE4381C0C75118A7856B0246C891@ala-mail02.corp.ad.wrs.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 22, 2008 at 11:59:12AM -0800, Stephens, Allan wrote:
> This patch eliminates warnings about a pair of undeclared symbols.

Hi Allan.

Last I looked there where ~90 sparse warnings for tipc.
I assume you are aware and that they are getting fixed.

	Sam - who would like to see an almost sparse clean kernel
