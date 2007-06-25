From: Ranko Zivojnovic <ranko@spidernet.net>
Subject: Re: [Bugme-new] [Bug 8668] New: HTB Deadlock
Date: Mon, 25 Jun 2007 14:37:55 +0300
Message-ID: <1182771475.4165.10.camel@ranko-fc2.spidernet.net>
References: <bug-8668-10286@http.bugzilla.kernel.org/>
	 <20070624222430.8d5b4bd7.akpm@linux-foundation.org>
	 <467F8ADA.7060702@trash.net>  <467F8B37.7030000@trash.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@kernel-bugs.osdl.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MPP-Goya.spidernet.net ([194.154.128.52]:55405 "EHLO
	mail0pop.spidernet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751180AbXFYLwt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2007 07:52:49 -0400
In-Reply-To: <467F8B37.7030000@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-06-25 at 11:30 +0200, Patrick McHardy wrote:
> Patrick McHardy wrote:
> > It is. This patch I had originally planned for 2.6.23 switches HTB
> > to the generic estimator, which shouldn't suffer from this.
> > 
> > Ranko, can you try if it fixes your timer problem?
> 
> 
> Forgot the patch ..

Will try it - yes.

R.


