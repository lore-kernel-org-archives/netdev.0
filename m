From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4 v2] sctp: fix association hangs due to off-by-one
 errors in sctp_tsnmap_grow()
Date: Thu, 21 Feb 2013 13:02:32 -0500 (EST)
Message-ID: <20130221.130232.875234888321258862.davem@davemloft.net>
References: <D64EC45690EF85409BA6C4730E0162244310DF62@G4W3231.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: lee.roberts@hp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <D64EC45690EF85409BA6C4730E0162244310DF62@G4W3231.americas.hpqcorp.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Roberts, Lee A." <lee.roberts@hp.com>
Date: Thu, 21 Feb 2013 17:57:46 +0000


When you are given feedback on patches you submit, you should wait
some time for all the feedback to settle, then resubmit your entire
series (not just the patches that needed changes).

> Patch applies to linux-3.8 kernel.

This is not appropriate to mention in a commit message, your patches
might get ported to -stable trees and elsewhere, and such a comment
looks awkward at best in such scenerios.
