From: Dmitry Yusupov <dmitry_yus@yahoo.com>
Subject: Re: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed
	Topics
Date: Wed, 30 Mar 2005 10:46:56 -0800
Message-ID: <1112208416.11620.42.camel@beastie>
References: <424346FE.20704@cs.wisc.edu>
	 <20050324233921.GZ14202@opteron.random>	<20050325034341.GV32638@waste.org>
	 <20050327035149.GD4053@g5.random> <20050327054831.GA15453@waste.org>
	 <1111905181.4753.15.camel@mylaptop>
	 <20050326224621.61f6d917.davem@davemloft.net>
	 <Pine.LNX.4.61.0503272245350.30885@chimarrao.boston.redhat.com>
	 <m1zmwn21hk.fsf@muc.de> <1112027284.5531.27.camel@mulgrave>
	 <20050329152008.GD63268@muc.de>  <1112116762.5088.65.camel@beastie>
	 <1112130512.1077.107.camel@jzny.localdomain>  <4249D0CB.2030506@hp.com>
	 <1112138018.1088.31.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hp.com>, netdev <netdev@oss.sgi.com>,
        ksummit-2005-discuss@thunk.org
Return-path: <netdev-bounce@oss.sgi.com>
To: open-iscsi@googlegroups.com
In-Reply-To: <1112138018.1088.31.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2005-03-29 at 18:13 -0500, jamal wrote:

> In any case i have seen horror stories of what happened to people
> who tried to encapsulate an already reliable protocol inside TCP in
> order to ship it across the big bad internet. I am pretty sure some
> knowledgeable people were involved in getting iscsi going so it cant be
> that simple. It would seem preferable to use SCTP instead.

Few problems with iSCSI over SCTP I see:

1) It is not as accelerated as TCP yet. But it will eventually. So it is
matter of time.

2) There is no working ietf draft for iSCSI over SCTP yet. AFAIK. It
will also take few more years.

3) It is not widely used just yet.

Dima
