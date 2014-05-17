From: Kelly Anderson <kelly@xilka.com>
Subject: Re: 3.14 tc oops
Date: Fri, 16 May 2014 21:28:16 -0600
Message-ID: <2501516.A9ihW45TvK@comer>
References: <1592838.91HrDxMk9i@comer> <3222104.QGqslXqjVx@comer> <CAM_iQpVVwE6+SgYKr5kiHhv0yE3-eRynxo5AkPSL5ZQ=aA5aJw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Daniel Borkmann <dborkman@redhat.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ar100.montanavision.com ([216.146.103.100]:55957 "EHLO
	xilka.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754887AbaEQDaU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 May 2014 23:30:20 -0400
In-Reply-To: <CAM_iQpVVwE6+SgYKr5kiHhv0yE3-eRynxo5AkPSL5ZQ=aA5aJw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday, May 16, 2014 17:18:52 Cong Wang wrote:
> On Mon, Apr 7, 2014 at 1:00 AM, Kelly Anderson <kelly@xilka.com> wrote:
> > Cong,
> > 
> > The patch did not fix the problem.
> > 
> > For your convenience, I've attached tc filter show for eth0 and eth1, as
> > well as a mangled version of my tcng input file.
> 
> Sorry that I totally forgot this thread....
> 
> I just tested a new patch (attached), it works for me, please verify it.
> 
> Thanks for the report anyway.

Great, the new patch seems to work fine with 3.14.4.  If you haven't done it 
yet, you should probably get that patch pulled into 3.14 stable.

Regards,

Kelly Anderson
