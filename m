From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Add eeprom_bad_csum_allow module option to e1000.
Date: Tue, 23 Oct 2007 14:53:39 -0700 (PDT)
Message-ID: <20071023.145339.55504234.davem@davemloft.net>
References: <471E2AD0.1000500@intel.com>
	<471E5C21.8030908@garzik.org>
	<20071023212026.GF7793@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, auke-jan.h.kok@intel.com, ajax@redhat.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49108
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751917AbXJWVxM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2007 17:53:12 -0400
In-Reply-To: <20071023212026.GF7793@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dave Jones <davej@redhat.com>
Date: Tue, 23 Oct 2007 17:20:26 -0400

> Indeed. This is a common enough problem that not including it causes
> more pain than its worth.  I have two affected boxes myself that I
> actually thought the hardware was dead before I tried ajax's patch.
>
> People aren't going to report this as a bug. They aren't going to
> try out patches, they're going to do what I did and stick another
> network card in the box and go on with life.
>
> Our users deserve better than this.

Seconded.  The resistence to this patch is just flat-out rediculious,
just like it was in the e100 case.

And I think all of this "e1000 is different!" talk is merely a
scarecrow for the fact that Intel simply doesn't want this patch
merged for some other reason.
