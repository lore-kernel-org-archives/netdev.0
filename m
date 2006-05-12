From: Michael Buesch <mb@bu3sch.de>
Subject: Re: Linux v2.6.17-rc4
Date: Fri, 12 May 2006 22:54:19 +0200
Message-ID: <200605122254.19615.mb@bu3sch.de>
References: <Pine.LNX.4.64.0605111640010.3866@g5.osdl.org> <200605121244.22511.mb@bu3sch.de> <20060512112318.GA2115@suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Erik Mouw <erik@harddisk-recovery.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:4301
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S932230AbWELUvm
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 May 2006 16:51:42 -0400
To: Olaf Hering <olh@suse.de>
In-Reply-To: <20060512112318.GA2115@suse.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 12 May 2006 13:23, you wrote:
> > > I got assertion failures in the bcm43xx driver:
> > > 
> > > bcm43xx: Chip ID 0x4318, rev 0x2
> > 
> > That is expected an non-fatal.
> 
> Is this one in the same category?
> [   79.087115] bcm43xx: WARNING: Writing invalid LOpair (low: 46, high: 104, index: 123)

> [   47.361435] bcm43xx: Chip ID 0x4318, rev 0x2
                                  ^^^^^^

Yes, same problem.

-- 
Greetings Michael.
