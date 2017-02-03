From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf: test for AND edge cases
Date: Fri, 03 Feb 2017 16:03:12 -0500 (EST)
Message-ID: <20170203.160312.750256875522827441.davem@davemloft.net>
References: <1486054838-5072-1-git-send-email-jbacik@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com, ast@fb.com,
        jannh@google.com, daniel@iogearbox.net
To: jbacik@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52588 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752331AbdBCVDQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 16:03:16 -0500
In-Reply-To: <1486054838-5072-1-git-send-email-jbacik@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Josef Bacik <jbacik@fb.com>
Date: Thu, 2 Feb 2017 12:00:38 -0500

> These two tests are based on the work done for f23cc643f9ba.  The first test is
> just a basic one to make sure we don't allow AND'ing negative values, even if it
> would result in a valid index for the array.  The second is a cleaned up version
> of the original testcase provided by Jann Horn that resulted in the commit.
> 
> Signed-off-by: Josef Bacik <jbacik@fb.com>

This doesn't apply cleanly to net-next, please respin.
