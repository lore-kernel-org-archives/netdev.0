From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/2] lec: Fix bug introduced by b67bfe0d42cac56c512dd5da4b1b347a23f4b70a
Date: Tue, 12 Aug 2014 16:34:36 +0400
Message-ID: <53EA09DC.5070909@cogentembedded.com>
References: <201408121224.s7CCOKCk008781@thirdoffive.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>,
	netdev@vger.kernel.org, linux-atm-general@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f172.google.com ([209.85.217.172]:35084 "EHLO
	mail-lb0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751482AbaHLMej (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2014 08:34:39 -0400
Received: by mail-lb0-f172.google.com with SMTP id z11so6988707lbi.17
        for <netdev@vger.kernel.org>; Tue, 12 Aug 2014 05:34:38 -0700 (PDT)
In-Reply-To: <201408121224.s7CCOKCk008781@thirdoffive.cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 8/12/2014 4:24 PM, chas williams - CONTRACTOR wrote:

> b67bfe0d42cac56c512dd5da4b1b347a23f4b70a dropped the node parameters

    Please also specify that commit's summary line in parens.

> from iterators which lec_tbl_walk() was using to iterate the list.

> Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>

WBR, Sergei
