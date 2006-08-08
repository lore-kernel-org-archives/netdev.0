From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] limit rt cache size
Date: Tue, 08 Aug 2006 01:34:52 -0700 (PDT)
Message-ID: <20060808.013452.24337231.davem@davemloft.net>
References: <20060807164842.GA3412@ms2.inr.ac.ru>
	<20060807.204214.68039839.davem@davemloft.net>
	<44D848B5.5080004@sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:60647
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932579AbWHHIes (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 04:34:48 -0400
To: dev@sw.ru
In-Reply-To: <44D848B5.5080004@sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kirill Korotaev <dev@sw.ru>
Date: Tue, 08 Aug 2006 12:17:57 +0400

> at least for i686 num_physpages includes highmem, so IMHO this bug
> was there for years:

Correct, I misread the x86 code.
