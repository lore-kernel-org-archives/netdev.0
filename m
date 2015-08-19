From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [iproute PATCH] ip-address.8.in: fix BNF syntax error
Date: Wed, 19 Aug 2015 16:34:56 -0700
Message-ID: <20150819163456.51fa9883@uryu.home.lan>
References: <9e56e3790a284b4199fa408d7e73d2a2@HQ1WP-EXMB11.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:25653 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750874AbbHSXfF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 19:35:05 -0400
In-Reply-To: <9e56e3790a284b4199fa408d7e73d2a2@HQ1WP-EXMB11.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 18 Aug 2015 16:11:12 +0000
Phil Sutter <phil@nwl.cc> wrote:

> The previous man page fixup introduced a syntax error due to missing
> opening bracket, which might crash some humanoid BNF parsers.
> 
> Fixes: 4e972d5 ("ip-address: fix and extend documentation")
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Both applied thanks.
