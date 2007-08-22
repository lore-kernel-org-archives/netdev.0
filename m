From: Paul Moore <paul.moore@hp.com>
Subject: Re: [RFC] Wild and crazy ideas involving struct sk_buff
Date: Wed, 22 Aug 2007 18:20:55 -0400
Message-ID: <200708221820.56516.paul.moore@hp.com>
References: <200708221631.34234.paul.moore@hp.com> <20070822.143627.62367286.davem@davemloft.net> <Xine.LNX.4.64.0708221506380.20059@us.intercode.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, tgraf@suug.ch,
	netdev@vger.kernel.org
To: James Morris <jmorris@namei.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:50604 "EHLO atlrel9.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934561AbXHVWV0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Aug 2007 18:21:26 -0400
In-Reply-To: <Xine.LNX.4.64.0708221506380.20059@us.intercode.com.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday, August 22 2007 6:09:36 pm James Morris wrote:
> On Wed, 22 Aug 2007, David Miller wrote:
> > From: Paul Moore <paul.moore@hp.com>
> > Date: Wed, 22 Aug 2007 17:26:36 -0400
> >
> > > Was it just a thought, or was there some actual design/code/patchset
> > > to go along with it that described the idea?
> >
> > It was a thought mentioned at the first two netconfs, but it
> > went nowhere because the more we discussed the implementation
> > the more horrific it began to sound :-)
>
> Don't forget Rusty's skb reservation patches from 1999...

I'm guessing those would probably need to be forward ported just a teensy 
weensy bit ;)

-- 
paul moore
linux security @ hp
