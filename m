From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH 0/3] bonding: various fixes
Date: Mon, 14 Mar 2011 17:04:35 -0400
Message-ID: <20110314210435.GZ11864@gospo.rdu.redhat.com>
References: <1300119726-17529-1-git-send-email-kernel@linuxace.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net
To: Phil Oester <kernel@linuxace.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39022 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751310Ab1CNVEk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Mar 2011 17:04:40 -0400
Content-Disposition: inline
In-Reply-To: <1300119726-17529-1-git-send-email-kernel@linuxace.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 14, 2011 at 09:22:03AM -0700, Phil Oester wrote:
> A few collected fixes to bonding.  Patches are against net-next,
> but should apply fine to 38-rc.   
> 
> Phil
> 
> 
>  bond_main.c  |   15 +++++++++++----
>  bond_sysfs.c |    5 ++++-
>  2 files changed, 15 insertions(+), 5 deletions(-)

All in the series look good.  Thanks for posting the queue cleanup,
Phil.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>


