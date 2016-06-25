From: Afzal Mohammed <afzal.mohd.ma@gmail.com>
Subject: Re: [PATCH] net: ethernet: ti: cpdma: switch to use genalloc
Date: Sat, 25 Jun 2016 14:03:29 +0530
Message-ID: <20160625083329.GA3795@afzalpc>
References: <20160623123620.11681-1-grygorii.strashko@ti.com>
 <576BDC64.3030908@linaro.org>
 <576CCD9B.2050700@ti.com>
 <20160624161541.GA23499@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mugunthan V N <mugunthanvnm@ti.com>,
	Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
	Grygorii Strashko <grygorii.strashko@ti.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Sekhar Nori <nsekhar@ti.com>, linux-kernel@vger.kernel.org,
	linux-omap@vger.kernel.org
To: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35156 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751141AbcFYIdm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jun 2016 04:33:42 -0400
Content-Disposition: inline
In-Reply-To: <20160624161541.GA23499@csclub.uwaterloo.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Fri, Jun 24, 2016 at 12:15:41PM -0400, Lennart Sorensen wrote:

> although the style does require using brackets for the else if the
> if required them.

As an aside, though most of the style rationale is K & R, K & R
consistently uses unbalanced braces for if-else-*

For a one that learns C unadultered from K & R, probably Kernel coding
style comes naturally, except for trivial things like above.

...a brick for the shed.

Regards
afzal
