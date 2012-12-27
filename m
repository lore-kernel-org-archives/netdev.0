From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: vxlan in Linux kernel 3.7
Date: Thu, 27 Dec 2012 11:43:10 -0800
Message-ID: <20121227114310.6033b986@nehalam.linuxnetplumber.net>
References: <A3CA455BB4F1DA4E92CB43AAF0E4BB1D0667E12B@MX01A.corp.emc.com>
	<20121227104916.4fb2af04@nehalam.linuxnetplumber.net>
	<A3CA455BB4F1DA4E92CB43AAF0E4BB1D0667E12C@MX01A.corp.emc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Qin, Xiaohong" <Xiaohong.Qin@emc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:52957 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752695Ab2L0Tob (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Dec 2012 14:44:31 -0500
In-Reply-To: <A3CA455BB4F1DA4E92CB43AAF0E4BB1D0667E12C@MX01A.corp.emc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 27 Dec 2012 13:56:51 -0500
"Qin, Xiaohong" <Xiaohong.Qin@emc.com> wrote:

> # ip -V
> ip utility, iproute2-ss111117
> 
> So I think I'm all set to give it a try?

That version is way to old to know about vxlan configuration.
The last digits of the iproute version are the date it was
released.  That date is November 17 2011 which is the 3.1 version.
You need 3.7 which was released on December 11 2012, or you can
use latest from iproute2 git repository.
