From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: NULL deref in bnx2 / crashes ? ( was: netconsole leads to stalled
 CPU task )
Date: Sat, 25 Aug 2012 16:01:52 +0800
Message-ID: <CAM_iQpWa49bZ+vv6WA3gpEciP8Z9pSxbZrAV9ySQjKj5CbZjfA@mail.gmail.com>
References: <CAF6-1L4wh0P-Wi-keN98wb-2V_avZYVE3ycf3tEe9SBpgK1dDQ@mail.gmail.com>
	<1345634026.5158.1084.camel@edumazet-glaptop>
	<CAF6-1L6zr5WJxo6FVk+2ya=EEs++u3x9iSrDxX-weBofLJuA1g@mail.gmail.com>
	<1345640757.5158.1321.camel@edumazet-glaptop>
	<CAF6-1L7nRoG10P=+QRb=LfL4O8K877zUD6L6d5EoCq-QNt1FWA@mail.gmail.com>
	<k14noo$lfj$1@ger.gmane.org>
	<k14poh$7bs$1@ger.gmane.org>
	<k14s5v$7bs$2@ger.gmane.org>
	<CAF6-1L6NDYhMuW7uJVt7ov1=Sca_G_bMjXNgUb4UnoQE2i9JmA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Sylvain Munaut <s.munaut@whatever-company.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:57887 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755039Ab2HYIBx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Aug 2012 04:01:53 -0400
Received: by dady13 with SMTP id y13so1400466dad.19
        for <netdev@vger.kernel.org>; Sat, 25 Aug 2012 01:01:52 -0700 (PDT)
In-Reply-To: <CAF6-1L6NDYhMuW7uJVt7ov1=Sca_G_bMjXNgUb4UnoQE2i9JmA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 24, 2012 at 5:50 PM, Sylvain Munaut
<s.munaut@whatever-company.com> wrote:
>
> I've just tested this patch on the intel machine and the behavior didn't change.
> When I do the netconsole modprobe, it sends a couple of line, the
> modprobe hangs and then a couple of second later the whole machine
> hangs, with nothing printed on the screen or anything.

Hi, Sylvain

I just sent a new patch:
http://marc.info/?l=linux-netdev&m=134588049503667&w=2

Please help to test it.

Thanks a lot!
