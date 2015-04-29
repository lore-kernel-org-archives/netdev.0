From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] bnx2x: minor cleanups related to TPA bits
Date: Wed, 29 Apr 2015 14:47:08 -0400 (EDT)
Message-ID: <20150429.144708.1814233126166838427.davem@davemloft.net>
References: <1430213663-5657-1-git-send-email-mschmidt@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Yuval.Mintz@qlogic.com,
	Ariel.Elior@qlogic.com, Dmitry.Kravkov@qlogic.com
To: mschmidt@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50082 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750791AbbD2SrK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 14:47:10 -0400
In-Reply-To: <1430213663-5657-1-git-send-email-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Schmidt <mschmidt@redhat.com>
Date: Tue, 28 Apr 2015 11:34:20 +0200

> I noticed some simplification possibilities while looking into the bug
> fixed by "bnx2x: really disable TPA if 'disable_tpa' is set'.
> 
> Michal Schmidt (3):
>   bnx2x: mark LRO as a fixed disabled feature if disable_tpa is set
>   bnx2x: merge fp->disable_tpa with fp->mode
>   bnx2x: remove {TPA,GRO}_ENABLE_FLAG

Can some maintainers of this driver please review these patches?
