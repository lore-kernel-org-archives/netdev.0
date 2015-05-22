From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] test_bpf: Add backward jump test case
Date: Fri, 22 May 2015 15:11:19 -0400 (EDT)
Message-ID: <20150522.151119.1223342901130247361.davem@davemloft.net>
References: <1432309000-11545-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: holzheu@linux.vnet.ibm.com, schwidefsky@de.ibm.com,
	daniel@iogearbox.net, netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49885 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756510AbbEVTLX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 15:11:23 -0400
In-Reply-To: <1432309000-11545-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Fri, 22 May 2015 08:36:40 -0700

> From: Michael Holzheu <holzheu@linux.vnet.ibm.com>
> 
> Currently the testsuite does not have a test case with a backward jump.
> The s390x JIT (kernel 4.0) had a bug in that area.
> So add one new test case for this now.
> 
> Signed-off-by: Michael Holzheu <holzheu@linux.vnet.ibm.com>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

Applied, thanks.
