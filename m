From: Sascha Hlusiak <contact@saschahlusiak.de>
Subject: Re: [PATCH 1/5] sit: Fail to create tunnel, if it already exists,
Date: Fri, 15 May 2009 16:15:14 +0200
Message-ID: <200905151615.15170.contact@saschahlusiak.de>
References: <1242391971-32583-1-git-send-email-contact@saschahlusiak.de> <20090515133007.GK25620@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:56218 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751159AbZEOOOJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2009 10:14:09 -0400
In-Reply-To: <20090515133007.GK25620@psychotron.englab.brq.redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Freitag 15 Mai 2009 15:30:08 schrieb Jiri Pirko:
> Fri, May 15, 2009 at 02:52:47PM CEST, contact@saschahlusiak.de wrote:
> >When locating the tunnel, do not continue if it is found. Otherwise
> >a different tunnel with similar configuration would be returned and
> >parts could be overwritten.
>
> You are missing Signed-off-by line in the whole patchset.

Thanks. Resent patchset with Signed-off-by lines and fixed the other warnings.
