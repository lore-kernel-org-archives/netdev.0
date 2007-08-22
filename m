From: James Morris <jmorris@namei.org>
Subject: Re: [RFC] Wild and crazy ideas involving struct sk_buff
Date: Wed, 22 Aug 2007 15:09:36 -0700 (PDT)
Message-ID: <Xine.LNX.4.64.0708221506380.20059@us.intercode.com.au>
References: <200708221631.34234.paul.moore@hp.com> <20070822212005.GR32236@postel.suug.ch>
 <200708221726.36783.paul.moore@hp.com> <20070822.143627.62367286.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: paul.moore@hp.com, tgraf@suug.ch, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from namei.org ([69.55.235.186]:50679 "EHLO us.intercode.com.au"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1759341AbXHVWJn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Aug 2007 18:09:43 -0400
In-Reply-To: <20070822.143627.62367286.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 22 Aug 2007, David Miller wrote:

> From: Paul Moore <paul.moore@hp.com>
> Date: Wed, 22 Aug 2007 17:26:36 -0400
> 
> > Was it just a thought, or was there some actual design/code/patchset
> > to go along with it that described the idea?
> 
> It was a thought mentioned at the first two netconfs, but it
> went nowhere because the more we discussed the implementation
> the more horrific it began to sound :-)

Don't forget Rusty's skb reservation patches from 1999...


-- 
James Morris
<jmorris@namei.org>
