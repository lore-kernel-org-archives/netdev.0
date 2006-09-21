From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [patch] d80211: fix WEP on big endian cpus
Date: Thu, 21 Sep 2006 21:28:59 +0200
Message-ID: <20060921212859.46d42e2c@logostar.upir.cz>
References: <20060910173649.GA6324@devicescape.com>
	<200609101747.21946.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Kimdon <david.kimdon@devicescape.com>,
	netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:7603 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1751441AbWIUT3E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2006 15:29:04 -0400
To: Michael Wu <flamingice@sourmilk.net>
In-Reply-To: <200609101747.21946.flamingice@sourmilk.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sun, 10 Sep 2006 17:47:16 -0400, Michael Wu pise:
> This patch fixes the endian issues with the ICV in WEP, as pointed out by 
> David Kimdon <david.kimdon@devicescape.com>, and uses __le32 where 
> appropriate to make things clear.

Applied to my tree. Thanks for the patch!

 Jiri

-- 
Jiri Benc
SUSE Labs
