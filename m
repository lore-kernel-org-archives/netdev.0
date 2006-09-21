From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [patch] d80211: fix multiple device ap support
Date: Thu, 21 Sep 2006 21:26:26 +0200
Message-ID: <20060921212626.036a362f@logostar.upir.cz>
References: <20060905185035.GA24499@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:65202 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1751445AbWIUT03 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2006 15:26:29 -0400
To: David Kimdon <david.kimdon@devicescape.com>
In-Reply-To: <20060905185035.GA24499@devicescape.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 5 Sep 2006 11:50:35 -0700, David Kimdon wrote:
> Another fix to the interpretation of dev_alloc_name() return value.
> dev_alloc_name() returns the number of the unit assigned or a negative
> errno code.

Applied to my tree. Thanks for the patch!

 Jiri

-- 
Jiri Benc
SUSE Labs
