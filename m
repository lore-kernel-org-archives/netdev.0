From: kuznet@ms2.inr.ac.ru
Subject: Re: raw ipv6 broken in 2.4.19
Date: Wed, 14 Aug 2002 02:18:50 +0400 (MSD)
Sender: owner-netdev@oss.sgi.com
Message-ID: <200208132218.CAA22224@sex.inr.ac.ru>
References: <Pine.LNX.4.44.0208140107570.1517-100000@u.domain.uli>
Mime-Version: 1.0
Cc: gandalf@wlug.westbo.se, netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: ja@ssi.bg (Julian Anastasov)
In-Reply-To: <Pine.LNX.4.44.0208140107570.1517-100000@u.domain.uli> from "Julian Anastasov" at Aug 14, 2 01:12:41 am
List-Id: netdev.vger.kernel.org

Hello!

> > Sorry? What do you mean? Checksumming routines must not have any alignment
> > constraints, they used with arbitrary combinations of alignments.
> 
> 	Do you believe, they have :) See the 2nd URL,

Well, if this is only in combination with zero length, it is not a disaster.

Alexey
