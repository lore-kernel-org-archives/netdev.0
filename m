From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: Re: [PATCH 4/6] [IPROUTE2]: Overhead calculation is now done in
	the kernel
Date: Wed, 12 Sep 2007 14:22:26 +0200
Message-ID: <1189599746.26927.35.camel@localhost.localdomain>
References: <1189592079.26927.25.camel@localhost.localdomain>
	 <20070912130509.0a6dea32@oldman>
Reply-To: jdb@comx.dk
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:34705 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967033AbXILMXA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 08:23:00 -0400
In-Reply-To: <20070912130509.0a6dea32@oldman>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-09-12 at 13:05 +0200, Stephen Hemminger wrote:

> How is this binary compatable with older kernels?

It will be binary compatable, as I use/rename some unused variables in
struct tc_ratespec.

-- 
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network developer
  Cand. Scient Datalog / MSc.
  Author of http://adsl-optimizer.dk
