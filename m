From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: netconsole fun
Date: Tue, 11 Dec 2012 04:51:26 +0000 (UTC)
Message-ID: <ka6e4e$6k5$1@ger.gmane.org>
References: <1355149033.3142.14.camel@thor>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:35965 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751625Ab2LKEvo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Dec 2012 23:51:44 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1TiHou-0004b1-NA
	for netdev@vger.kernel.org; Tue, 11 Dec 2012 05:51:52 +0100
Received: from 112.122.183.103 ([112.122.183.103])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 11 Dec 2012 05:51:52 +0100
Received: from xiyou.wangcong by 112.122.183.103 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 11 Dec 2012 05:51:52 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 10 Dec 2012 at 14:17 GMT, Peter Hurley <peter@hurleysoftware.com> wrote:
> Now that netpoll has been disabled for slaved devices, is there a
> recommended method of running netconsole on a machine that has a slaved
> device?
>

Yes, running it on the master device instead.
