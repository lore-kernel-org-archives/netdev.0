From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: Please pull 'rt2x00' branch of wireless-2.6
Date: Wed, 19 Sep 2007 22:59:10 +0200
Message-ID: <200709192259.10694.IvDoorn@gmail.com>
References: <20070918213202.GJ4940@tuxdriver.com> <200709192031.19934.IvDoorn@gmail.com> <20070919191156.GC5483@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jeff@garzik.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.179]:56195 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757038AbXISUq0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 16:46:26 -0400
Received: by py-out-1112.google.com with SMTP id u77so594065pyb
        for <netdev@vger.kernel.org>; Wed, 19 Sep 2007 13:46:25 -0700 (PDT)
In-Reply-To: <20070919191156.GC5483@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 19 September 2007, John W. Linville wrote:
> On Wed, Sep 19, 2007 at 08:31:19PM +0200, Ivo van Doorn wrote:
> 
> > > Ivo and his team may feel I am jumping the gun a bit -- they have
> > > a few more random bugs they wanted to squash before going upstream.
> > > But since they are bugs, any fixes should still be able to be applied
> > > in the -rc phase of 2.6.24.  In the meantime, I definitely think it
> > > would be better to get this code into mainline rather than keeping
> > > it out of stream.
> > 
> > With 2.6.23 not yet released, I assume we still have a few months to get
> > rt2x00 shaped up to be really ready for 2.6.24?
> > Because I am indeed not really happy with this early merge, but I'll do my
> > best to resolve the last outstanding bugs as soon as possible.
> 
> Ivo,
> 
> Having failed to ask for permission, this is where I ask for your
> forgiveness.  Please forgive me! :-)

Not a problem. :)

> As Dave said, merging rt2x00 now is undoubtedly better than having
> no driver at all.  I appreciate your understanding and cooperation!

I was just surprised to see the pull request floating by,
but you were right, there should be enough time to resolve the remaining issues
and it is actually a good thing to start moving rt2x00 further upstream.

Ivo
