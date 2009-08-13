From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [net-next 00/36] bnx2x patch series
Date: Thu, 13 Aug 2009 09:35:25 +0300
Message-ID: <1250145325.27379.190.camel@lb-tlvb-eilong>
References: <1250101162.27379.151.camel@lb-tlvb-eilong>
 <20090812.230912.102740872.davem@davemloft.net>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Yaniv Rosner" <yaniv.rosner@broadcom.com>,
	"Vladislav Zolotarov" <vladz@broadcom.com>,
	"Yitchak Gertner" <yitchak.gertner@broadcom.com>,
	"Benjamin Li" <benli@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3350 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751014AbZHMGgM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Aug 2009 02:36:12 -0400
In-Reply-To: <20090812.230912.102740872.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-08-12 at 23:09 -0700, David Miller wrote:
> From: "Eilon Greenstein" <eilong@broadcom.com>
> Date: Wed, 12 Aug 2009 21:19:22 +0300
> 
> > Here is a patch series for the bnx2x. This patch series also replace the
> > FW, so
> > it contains two big blobs - the new fw and the removal of the old one.
> > Those
> > patches do not contain anything but the ihex - the actually change to
> > the driver
> > is in patch number 2 which is small enough to fit the mailing list.
> > 
> > For those who wish to see all the patches, including the ihex, I also
> > updated
> > http://linux.broadcom.com/eilong/ to contain this patch series.
> > 
> > Please consider applying to net-next.
> 
> I've applied it all, but sincerely this is absolutely the last
> time I'm taking in a patch bomb for a Broadcom ethernet driver.
> 
> If it's new stuff, keep it to ~10 patches.
> 
> If it's bug fixes outside of the merge window, keep it at
> 2 or 3 patches.
> 
> Post them very near to when you write them, so people have a chance of
> actually reviewing your work (I guarentee I am the only non-Broadcom
> person who looked over all 36 patches, or who ever will).
> 
> "Early and often" as it were...
> 
Will do!

Thanks,
Eilon


