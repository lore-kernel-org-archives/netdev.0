From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC: 2.6 patch] net/irda/irias_object.c: remove unused exports
Date: Sat, 15 Apr 2006 02:27:02 -0700 (PDT)
Message-ID: <20060415.022702.120267858.davem@davemloft.net>
References: <20060414114446.GL4162@stusta.de>
	<Pine.LNX.4.58.0604151157320.1032@irie>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bunk@stusta.de, jt@hpl.hp.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:31456
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932354AbWDOJbK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Apr 2006 05:31:10 -0400
To: samuel.ortiz@nokia.com
In-Reply-To: <Pine.LNX.4.58.0604151157320.1032@irie>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Samuel Ortiz <samuel.ortiz@nokia.com>
Date: Sat, 15 Apr 2006 11:58:21 +0300 (EEST)

> On Fri, 14 Apr 2006, ext Adrian Bunk wrote:
> 
> > This patch removes the following unused EXPORT_SYMBOL's:
> > - irias_find_attrib
> > - irias_new_string_value
> > - irias_new_octseq_value
> >
> > Signed-off-by: Adrian Bunk <bunk@stusta.de>
> Looks good to me.
> 
> Signed-off-by: Samuel Ortiz <samuel.ortiz@nokia.com>

Sam, just add this to your IRDA queue.  Ok?
