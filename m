From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 1/1] tun: change speed from 10M to dynamically configured
Date: Sat, 14 Feb 2015 00:15:24 +0100
Message-ID: <20150213231524.GA1800@electric-eye.fr.zoreil.com>
References: <1423808353-8722-1-git-send-email-Yanjun.Zhu@windriver.com>
 <1423808353-8722-2-git-send-email-Yanjun.Zhu@windriver.com>
 <20150213212830.GA29912@electric-eye.fr.zoreil.com>
 <54DE6D67.5000601@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Zhu Yanjun <Yanjun.Zhu@windriver.com>, netdev@vger.kernel.org,
	mst@redhat.com, jasowang@redhat.com, viro@zeniv.linux.org.uk,
	davem@davemloft.net, sergei.shtylyov@cogentembedded.com,
	jonathon.reinhart@gmail.com
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:43116 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753111AbbBMXPl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Feb 2015 18:15:41 -0500
Content-Disposition: inline
In-Reply-To: <54DE6D67.5000601@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rick Jones <rick.jones2@hp.com> :
> It is perhaps as much a bug in the monitoring tools as anything else, but I
> have come across (versions of) software - such as collectl I think - which
> when presented with counters indicating a data rate higher than the reported
> link rate of the interface get somewhat cranky.

It won't fix said software but the device should thus allow almost any
speed.

-- 
Ueimor
