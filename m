From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH net] skge: dma_sync the whole receive buffer
Date: Wed, 21 Aug 2013 21:00:41 -0700
Message-ID: <20130822040041.GA4821@kroah.com>
References: <20130813180036.3e639789@nehalam.linuxnetplumber.net>
 <520B59D3.4020103@gmail.com>
 <20130814092022.494caf2b@nehalam.linuxnetplumber.net>
 <520BCC72.8040002@gmail.com>
 <20130815084117.2f48fc58@nehalam.linuxnetplumber.net>
 <52116B9C.8050003@gmail.com>
 <5212E249.2050203@gmail.com>
 <5214E4FB.7010208@gmail.com>
 <20130822004023.GA26938@kroah.com>
 <521585C9.3040809@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>
To: poma <pomidorabelisima@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:37636 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753442Ab3HVD6s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 23:58:48 -0400
Content-Disposition: inline
In-Reply-To: <521585C9.3040809@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 22, 2013 at 05:30:17AM +0200, poma wrote:
> On 22.08.2013 02:40, Greg KH wrote:
> > On Wed, Aug 21, 2013 at 06:04:11PM +0200, poma wrote:
> >> Signor Greg you are supposed to be very resourceful guy, especially in
> >> matters concerning the hardware, so please if you can set aside your
> >> valuable time and help us finally resolve this issue.
> > 
> > Please take it up with Stephen, it's his driver, not mine.
> > 
> > greg k-h
> > 
> 
> I guess I wrongly assumed that developers help each other when they get
> stuck. Isn't it obvious that Steph and Dave already decided to ship the
> broken module in da birthday kernel.

No, it's not obvious at all.  If it's broken for you, please work with
them, not against them by trying to go around their back to someone
else.  I have nothing to do with networking drivers, that's Stephen and
David's area of the kernel, so there's nothing I can even do here,
sorry.

greg k-h
