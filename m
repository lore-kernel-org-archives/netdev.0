From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] 6lowpan: mac802154: fix coding style issues
Date: Mon, 07 Jul 2014 20:55:41 -0700 (PDT)
Message-ID: <20140707.205541.667410963063647490.davem@davemloft.net>
References: <1404271869-2316-1-git-send-email-varkab@cdac.in>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alex.bluesman.smirnov@gmail.com,
	dbaryshkov@gmail.com, linux-zigbee-devel@lists.sourceforge.net,
	varkab@cdac.in
To: varkabhadram@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48657 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752698AbaGHDzm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2014 23:55:42 -0400
In-Reply-To: <1404271869-2316-1-git-send-email-varkab@cdac.in>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Varka Bhadram <varkabhadram@gmail.com>
Date: Wed,  2 Jul 2014 09:01:09 +0530

> This patch fixed the coding style issues reported by checkpatch.pl
> 
> following issues fixed:
> 	CHECK: Alignment should match open parenthesis
> 	WARNING: line over 80 characters
> 	CHECK: Blank lines aren't necessary before a close brace '}'
> 	WARNING: networking block comments don't use an empty /* line, use /* Comment...
> 	WARNING: Missing a blank line after declarations
> 	WARNING: networking block comments start with * on subsequent lines
> 	CHECK: braces {} should be used on all arms of this statement
> 
> Signed-off-by: Varka Bhadram <varkab@cdac.in>
> Tested-by: Alexander Aring <alex.aring@gmail.com>

Applied, thanks.
