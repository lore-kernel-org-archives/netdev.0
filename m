From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] d80211: extend extra_hdr_room to be a bytecount
Date: Wed, 11 Oct 2006 22:43:34 +0200
Message-ID: <200610112243.34877.mb@bu3sch.de>
References: <200610111158.28434.mb@bu3sch.de> <20061011145923.GA6785@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:31435
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1161261AbWJKUoD
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Oct 2006 16:44:03 -0400
To: David Kimdon <david.kimdon@devicescape.com>
In-Reply-To: <20061011145923.GA6785@devicescape.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 11 October 2006 16:59, David Kimdon wrote:
> Perhaps rename it to extra_tx_headroom?
>  - existing users would then need to take notice of the change
>  - the name 'extra_tx_headroom' is more descriptive of what it actually is

Oh, yeah. This was lazyman's solution ;)
I will send an updated patch.

-- 
Greetings Michael.
