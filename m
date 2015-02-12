From: Martin Lau <kafai@fb.com>
Subject: Re: [RFC PATCH net-next] ipv6: fix ipv6_cow_metrics for non DST_HOST
 case
Date: Thu, 12 Feb 2015 13:39:18 -0800
Message-ID: <20150212213918.GD1916791@devbig242.prn2.facebook.com>
References: <1423771650-870555-1-git-send-email-kafai@fb.com>
 <1423776759.3051.5.camel@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	Kernel Team <kernel-team@fb.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:61730 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750810AbbBLVj1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2015 16:39:27 -0500
Content-Disposition: inline
In-Reply-To: <1423776759.3051.5.camel@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 12, 2015 at 04:32:39PM -0500, Hannes Frederic Sowa wrote:
> This fixes 8e2ec639173f325 ("ipv6: don't use inetpeer to store metrics
> for routes.")?
Correct. I will add the 'Fixes' tag and repost.

Thanks!
--Martin
