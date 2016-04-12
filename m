From: Julian Anastasov <ja@ssi.bg>
Subject: Re: Issue with ping source address display
Date: Tue, 12 Apr 2016 22:38:55 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1604122235020.1611@ja.home.ssi.bg>
References: <570D35CF.9070006@orlandi.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Daniele Orlandi <daniele@orlandi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:34864 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932653AbcDLTjX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Apr 2016 15:39:23 -0400
In-Reply-To: <570D35CF.9070006@orlandi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Tue, 12 Apr 2016, Daniele Orlandi wrote:

> I noticed that when ping receives ICMP messages from different sources
> the first IP address is always used and displayed:
> 
> 
> vihai@seviolab:~$ ping -V
> ping utility, iputils-s20121221

	What is the kernel version?

Regards
