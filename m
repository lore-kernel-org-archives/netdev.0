From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH] bnx2x: bug fix when loading after SAN boot
Date: Sun, 6 May 2012 20:06:15 +0300
Message-ID: <1336323975.12363.24.camel@lb-tlvb-eilong.il.broadcom.com>
References: <1336033320-16440-1-git-send-email-ariele@broadcom.com>
 <20120504.115753.1701261151183409987.davem@davemloft.net>
 <1336158940.12363.19.camel@lb-tlvb-eilong.il.broadcom.com>
 <20120506.123834.956789615986300329.davem@davemloft.net>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: ariele@broadcom.com, netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3927 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753990Ab2EFRGa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 May 2012 13:06:30 -0400
In-Reply-To: <20120506.123834.956789615986300329.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-05-06 at 12:38 -0400, David Miller wrote:
> From: "Eilon Greenstein" <eilong@broadcom.com>
> Date: Fri, 4 May 2012 22:15:40 +0300
> 
> > On Fri, 2012-05-04 at 11:57 -0400, David Miller wrote:
> >> From: "Ariel Elior" <ariele@broadcom.com>
> >> Date: Thu, 3 May 2012 11:22:00 +0300
> >> 
> >> > +	/* clear hw from errors which mnay have resulted from an interrupted
> >> > +	 * dmae transaction.
> >> > +	 */
> >> 
> >> Please fix the typos in this comment.
> >> 
> > 
> > Sure - thanks for pointing that out:
> > 
> > Subject: [PATCH net v2] bnx2x: bug fix when loading after SAN boot
> 
> Don't reply to a discussion with a patch you intend me to apply.
> 
> When you do that, I have to edit all of this other crap in the
> thread out of the commit message.  That makes more work for me.
> 
> Always post new patches as fresh patch postings to the list.

Done.
