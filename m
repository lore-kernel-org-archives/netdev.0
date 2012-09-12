From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: NULL deref in bnx2 / crashes ? ( was: netconsole leads to
 stalled CPU task )
Date: Wed, 12 Sep 2012 12:49:24 +0000 (UTC)
Message-ID: <k2q0ck$rpr$1@ger.gmane.org>
References: <CAF6-1L4wh0P-Wi-keN98wb-2V_avZYVE3ycf3tEe9SBpgK1dDQ@mail.gmail.com>
 <1345634026.5158.1084.camel@edumazet-glaptop>
 <CAF6-1L6zr5WJxo6FVk+2ya=EEs++u3x9iSrDxX-weBofLJuA1g@mail.gmail.com>
 <1345640757.5158.1321.camel@edumazet-glaptop>
 <CAF6-1L5hKU-VM0E5vCwExJ4kb8YB=ndotgfH7pbpxO6Q7+JHUQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:45829 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754863Ab2ILMtg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Sep 2012 08:49:36 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1TBmNt-0002Xb-VH
	for netdev@vger.kernel.org; Wed, 12 Sep 2012 14:49:37 +0200
Received: from 112.132.200.126 ([112.132.200.126])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 12 Sep 2012 14:49:37 +0200
Received: from xiyou.wangcong by 112.132.200.126 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 12 Sep 2012 14:49:37 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 12 Sep 2012 at 11:53 GMT, Sylvain Munaut <s.munaut@whatever-company.com> wrote:
> Hi Eric,
>
> AFAICT, the following patch was never merged but I just confirmed that
> I do need it over 3.6-rc5 for things to work properly.
>

Yes, indeed.

Eric, please resend your patch?
