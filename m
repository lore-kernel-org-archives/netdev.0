From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [Cbe-oss-dev] [PATCH 0/2] RFC: PS3 network driver
Date: Fri, 1 Jun 2007 23:05:42 +0200
Message-ID: <200706012305.43233.arnd@arndb.de>
References: <20070601142140.2C28.MOKUNO@sm.sony.co.jp> <20070601091259.GA2334@infradead.org> <46604544.4060503@am.sony.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Geoff Levand <geoffrey.levand@am.sony.com>,
	Christoph Hellwig <hch@infradead.org>, netdev@vger.kernel.org
To: cbe-oss-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:56959 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752166AbXFBMAt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jun 2007 08:00:49 -0400
In-Reply-To: <46604544.4060503@am.sony.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 01 June 2007, Geoff Levand wrote:
> 
> > What happened to the idea of incorporating support into spidernet?
> 
> That is still our goal, but as a first step we want to at least get
> some Ethernet support included for end users.

Right, I agree that having two drivers is a better medium-term solution,
since the two have diverged significantly already, and getting all
the PS3 code back into spidernet would probably cause it to
become less stable and will take much longer than I'd want to
wait fo having PS3 fully supported.

	Arnd <><
