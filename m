From: David Greaves <david@dgreaves.com>
Subject: Re: [RFD] Layering: Use-Case Composers (was: DRBD - what is it,	anyways?
 [compare with e.g. NBD + MD raid])
Date: Mon, 13 Aug 2007 08:51:34 +0100
Message-ID: <46C00D86.4090403@dgreaves.com>
References: <200708121335.17267.a1426z@gawab.com> <Pine.LNX.4.64.0708121325170.28963@fbirervta.pbzchgretzou.qr> <Pine.LNX.4.64.0708120933210.19502@asgard.lang.hm> <Pine.LNX.4.64.0708121901290.28963@fbirervta.pbzchgretzou.qr> <20070812174549.GA2915@teal.hq.k1024.org> <46BFB6BB.80406@steeleye.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jan Engelhardt <jengelh@computergmbh.de>, david@lang.hm,
	Al Boldi <a1426z@gawab.com>, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org,
	linux-raid@vger.kernel.org
To: Paul Clements <paul.clements@steeleye.com>
Return-path: <linux-raid-owner@vger.kernel.org>
In-Reply-To: <46BFB6BB.80406@steeleye.com>
Sender: linux-raid-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Paul Clements wrote:
> Well, if people would like to see a timeout option, I actually coded up 
> a patch a couple of years ago to do just that, but I never got it into 
> mainline because you can do almost as well by doing a check at 
> user-level (I basically ping the nbd connection periodically and if it 
> fails, I kill -9 the nbd-client).


Yes please.

David

