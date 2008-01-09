From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: Re: [ANNOUNCE] bridge-utils 1.4
Date: Wed, 9 Jan 2008 08:40:35 +0200
Message-ID: <20080109063654.M87339@visp.net.lb>
References: <20080108085607.37ab168f@deepthought>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>,
	bridge@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:37461 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750882AbYAIGkr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 01:40:47 -0500
In-Reply-To: <20080108085607.37ab168f@deepthought>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


As mentioned in
http://marc.info/?l=linux-bridge&m=113105949718826&w=2

Released package doesn't contain ./configure script

For people who know what is make on, it is easy to run autoconf , but some 
know only how to use ./configure :-)

Other than this, it is works fine with me, but i didn't test it deeply yet.

On Tue, 8 Jan 2008 08:56:07 -0800, Stephen Hemminger wrote
> Minor update to bridge-utils. Mostly fixing bugs in usage of sysfs.
> 
> Release tarball:
>   http://downloads.sourceforge.net/bridge/bridge-utils-1.4.tar.gz
> 
> Alon Bar-Lev (1):
>       Allow bridge-utils to run when no TCP/IP is available
> 
> Denys Vlasenko (1):
>       fix use of sysfs (affects 32/64 bit compat)
> 
> Jeremy Jackson (1):
>       Fix parsing of port_id's (hex).
> 
> Stephen Hemminger (3):
>       Add ignore for generated files.
>       Update gitignore
>       Use linux/if.h rather than net/if.h
> 
> -- 
> Stephen Hemminger <stephen.hemminger@vyatta.com>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

