From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [iproute PATCH v2] ip{,6}tunnel: have a shared stats
 parser/printer
Date: Fri, 18 Dec 2015 11:47:00 -0800
Message-ID: <20151218114700.58356324@xeon-e3>
References: <20151218105225.GA19288@orbyte.nwl.cc>
	<1450436286-14882-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:11574 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932554AbbLRTrA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2015 14:47:00 -0500
In-Reply-To: <1450436286-14882-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 18 Dec 2015 11:58:06 +0100
Phil Sutter <phil@nwl.cc> wrote:

> This has a slight side-effect of not aborting when /proc/net/dev is
> malformed, but OTOH stats are not parsed for uninteresting interfaces.
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>
> ---
> Changes since v1:
> - Fix conflict resolution (sscan from 'buf' instead of 'ptr').

Applied thanks.
