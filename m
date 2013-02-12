From: Larry Baker <baker@usgs.gov>
Subject: Re: decnet: /proc/sys/net/decnet sysctl entries disappear
Date: Mon, 11 Feb 2013 17:30:44 -0800
Message-ID: <62023A63-C136-4117-85B3-CB96A49E546A@usgs.gov>
References: <FAAC90D7-8126-44CA-AACF-A5F8237C1A8E@usgs.gov> <1360629988.2701.23.camel@bwh-desktop.uk.solarflarecom.com> <1360630903.2701.26.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0 (Apple Message framework v1085)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gscamnlh01.wr.usgs.gov ([130.118.9.68]:60817 "EHLO
	gscamnlh01.wr.usgs.gov" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932675Ab3BLBap convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2013 20:30:45 -0500
In-Reply-To: <1360630903.2701.26.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11 Feb 2013, at 5:01 PM, Ben Hutchings wrote:

> Each patch should do one thing.  So send one patch with the sysctl fix,
> and additional patches for the other changes.

The decnet module banner has not changed in many years; that is why I changed it.  I also used a numbering scheme for the banner that matched the patch file name.  Should each of my patch submissions update the banner?  Or, does the decnet module maintainer do that?

FYI.  As of a couple years or so ago, the person that used to do this on the linux-decnet-user@lists.sourceforge.net moved on.  I'm trying to help others like myself that use this code.  Thankfully, someone has been updating it as the kernel network APIs have been changing.  I have to find out from someone here in our IT management what I am allowed to sign/agree to.  As you can see, I work for the US Government; I don't get to decide what I am authorized to commit the government to.

Larry Baker
US Geological Survey
650-329-5608
baker@usgs.gov
