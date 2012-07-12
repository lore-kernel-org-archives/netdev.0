From: Dave Jones <davej@redhat.com>
Subject: Re: 3.5rc6 sctp panic
Date: Wed, 11 Jul 2012 23:18:16 -0400
Message-ID: <20120712031816.GA26645@redhat.com>
References: <CAPgLHd9OESfaKP9n6=S9ziXW6Zzyo54fZ2fPXUZY88Jp_e0=hA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, vyasevich@gmail.com, sri@us.ibm.com
To: Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21113 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750976Ab2GLDSX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jul 2012 23:18:23 -0400
Content-Disposition: inline
In-Reply-To: <CAPgLHd9OESfaKP9n6=S9ziXW6Zzyo54fZ2fPXUZY88Jp_e0=hA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 12, 2012 at 11:12:47AM +0800, Wei Yongjun wrote:
 > On 07/11/2012 08:08 AM, Dave Jones wrote:
 > > I just hit this while fuzz testing, and the box locked up immediately afterwards.
 > > The serial log was a little mangled, I did my best to clean it up..
 > 
 > Hi Dave,
 > 
 > Can you share your test program?

http://codemonkey.org.uk/projects/trinity/

	Dave
