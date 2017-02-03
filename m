From: Josef Bacik <jbacik@fb.com>
Subject: Re: [PATCH net-next] bpf: test for AND edge cases
Date: Fri, 3 Feb 2017 16:21:28 -0500
Message-ID: <1486156888.8856.1.camel@fb.com>
References: <1486054838-5072-1-git-send-email-jbacik@fb.com>
         <20170203.160312.750256875522827441.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: <netdev@vger.kernel.org>, <kernel-team@fb.com>, <ast@fb.com>,
        <jannh@google.com>, <daniel@iogearbox.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:36103 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752547AbdBCVWU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 16:22:20 -0500
In-Reply-To: <20170203.160312.750256875522827441.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-02-03 at 16:03 -0500, David Miller wrote:
> From: Josef Bacik <jbacik@fb.com>
> Date: Thu, 2 Feb 2017 12:00:38 -0500
> 
> > 
> > These two tests are based on the work done for f23cc643f9ba.  The
> > first test is
> > just a basic one to make sure we don't allow AND'ing negative
> > values, even if it
> > would result in a valid index for the array.  The second is a
> > cleaned up version
> > of the original testcase provided by Jann Horn that resulted in the
> > commit.
> > 
> > Signed-off-by: Josef Bacik <jbacik@fb.com>
> This doesn't apply cleanly to net-next, please respin.

Ugh sorry did it on the wrong branch, I'll send an updated one shortly.
 Thanks,

Josef
