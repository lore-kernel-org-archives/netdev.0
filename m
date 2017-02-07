From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next][v2] bpf: test for AND edge cases
Date: Mon, 06 Feb 2017 22:36:17 -0500 (EST)
Message-ID: <20170206.223617.1798901649248376676.davem@davemloft.net>
References: <1486157123-11066-1-git-send-email-jbacik@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kernel-team@fb.com, netdev@vger.kernel.org
To: jbacik@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56602 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751164AbdBGDgT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 22:36:19 -0500
In-Reply-To: <1486157123-11066-1-git-send-email-jbacik@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Josef Bacik <jbacik@fb.com>
Date: Fri, 3 Feb 2017 16:25:23 -0500

> These two tests are based on the work done for f23cc643f9ba.  The first test is
> just a basic one to make sure we don't allow AND'ing negative values, even if it
> would result in a valid index for the array.  The second is a cleaned up version
> of the original testcase provided by Jann Horn that resulted in the commit.
> 
> Acked-by: Alexei Starovoitov <ast@kernel.org>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>
> Signed-off-by: Josef Bacik <jbacik@fb.com>
> ---
> v1->v2:
> -rebased onto net-next

Applied.
