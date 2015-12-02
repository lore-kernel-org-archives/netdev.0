From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: ipsec impact on performance
Date: Wed, 2 Dec 2015 16:47:08 -0500
Message-ID: <20151202214708.GF15262@oracle.com>
References: <20151201175953.GC21252@oracle.com>
 <CALx6S35uLqbuJTAFLMeT-BcyZw_fksz+7BkS=Nt7_3-nYMHF2A@mail.gmail.com>
 <20151201183720.GE21252@oracle.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CBE0ED7@AcuExch.aculab.com>
 <20151202121156.GK23178@oracle.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CBE0F39@AcuExch.aculab.com>
 <20151202205028.GB15262@oracle.com>
 <CALx6S34yqw_vJ+r21Br9O7y5NqzvA264ot7=GBTHe=FxWqh=AQ@mail.gmail.com>
 <20151202211201.GD15262@oracle.com>
 <CALx6S36gcbJRJOTdUhgZGVbe4YzBeuBgv105kXLMyDSBBQ_56Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Laight <David.Laight@aculab.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"linux-crypto@vger.kernel.org" <linux-crypto@vger.kernel.org>,
	Rick Jones <rick.jones2@hpe.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CALx6S36gcbJRJOTdUhgZGVbe4YzBeuBgv105kXLMyDSBBQ_56Q@mail.gmail.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On (12/02/15 13:44), Tom Herbert wrote:
> > IPv6 would be an interesting academic exercise, but it's going
> > to be a while before we get RDS-TCP to go over IPv6.
> >
> Huh? Who said anything about RDS-TCP? I thought you were trying to
> improve IPsec performance...

yes, and it would be nice to find out that IPsec for IPv6 is
fast, but I'm afraid there are a lot of IPv4 use cases out there that
need the same thing for IPv4 too (first?).

--Sowmini
