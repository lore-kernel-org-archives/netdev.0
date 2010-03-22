From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: 8021p to dscp remarking
Date: Mon, 22 Mar 2010 10:05:11 -0700 (PDT)
Message-ID: <26654477.5921269277511551.JavaMail.root@tahiti.vyatta.com>
References: <70376CA23424B34D86F1C7DE6B997343017F72C982@VSHINMSMBX01.vshodc.lntinfotech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Smital Desai <Smital.Desai@lntinfotech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60641 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750905Ab0CVRF0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Mar 2010 13:05:26 -0400
In-Reply-To: <70376CA23424B34D86F1C7DE6B997343017F72C982@VSHINMSMBX01.vshodc.lntinfotech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


----- "Smital Desai" <Smital.Desai@lntinfotech.com> wrote:

> Hello
> 
> Is it possible to support 8021p -> Dscp remarking in kernel for the
> routers that
> are not supporting such kind of remarking mechanism at hardware level
> ?
> 
> Any such support available in latest kernel ?
> 
> Any help / suggestions  will be appreciated .
> 
> Thanks,
> Smital Desai

dsmark queue discipline with appropriate filters.
