From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH 2/2]d80211: add hardware scan callback
Date: Thu, 21 Sep 2006 21:22:16 +0200
Message-ID: <20060921212216.2eb88d49@logostar.upir.cz>
References: <1156494733.21483.14.camel@devlinux-hong>
	<20060830191058.14275f74@griffin.suse.cz>
	<1157081867.11040.41.camel@devlinux-hong>
	<1157092863.2878.13.camel@ux156>
	<1157096078.11534.4.camel@devlinux-hong>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>, netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:21938 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1751475AbWIUTWY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2006 15:22:24 -0400
To: Hong Liu <hong.liu@intel.com>
In-Reply-To: <1157096078.11534.4.camel@devlinux-hong>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 01 Sep 2006 15:34:38 +0800, Hong Liu wrote:
> Thanks for point this out!
> Change to only set sta_scanning to 1 if hw_scan successes.

Applied to my tree. Thanks for the patch!

 Jiri

-- 
Jiri Benc
SUSE Labs
