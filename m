From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH 0/3] bnx2x: minor cleanups related to TPA bits
Date: Tue, 28 Apr 2015 10:45:17 +0000
Message-ID: <B5657A6538887040AD3A81F1008BEC63D2406E@AVMB1.qlogic.org>
References: <1430213663-5657-1-git-send-email-mschmidt@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Ariel Elior <Ariel.Elior@qlogic.com>,
	Dmitry Kravkov <Dmitry.Kravkov@qlogic.com>,
	David Miller <davem@davemloft.net>
To: Michal Schmidt <mschmidt@redhat.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:17853 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932699AbbD1KpY convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Apr 2015 06:45:24 -0400
In-Reply-To: <1430213663-5657-1-git-send-email-mschmidt@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I noticed some simplification possibilities while looking into the bug fixed by
> "bnx2x: really disable TPA if 'disable_tpa' is set'.
> 
> Michal Schmidt (3):
>   bnx2x: mark LRO as a fixed disabled feature if disable_tpa is set
>   bnx2x: merge fp->disable_tpa with fp->mode
>   bnx2x: remove {TPA,GRO}_ENABLE_FLAG
> 

Looking good; Thanks Michal.

Acked-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
