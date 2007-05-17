From: David Miller <davem@davemloft.net>
Subject: Re: Correct rp_filter help text.
Date: Thu, 17 May 2007 15:01:49 -0700 (PDT)
Message-ID: <20070517.150149.51842489.davem@davemloft.net>
References: <20070517215819.GA8580@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41172
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756512AbXEQWBs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2007 18:01:48 -0400
In-Reply-To: <20070517215819.GA8580@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dave Jones <davej@redhat.com>
Date: Thu, 17 May 2007 17:58:19 -0400

> As mentioned in http://bugzilla.kernel.org/show_bug.cgi?id=5015
> The helptext implies that this is on by default.
> This may be true on some distros (Fedora/RHEL have it enabled
> in /etc/sysctl.conf), but the kernel defaults to it off.
> 
> Signed-off-by: Dave Jones <davej@redhat.com>

Thanks Dave, I'll apply this, thanks.
