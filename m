From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] bpf: test for AND edge cases
Date: Thu, 02 Feb 2017 21:20:26 +0100
Message-ID: <5893948A.2050505@iogearbox.net>
References: <1486054838-5072-1-git-send-email-jbacik@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Josef Bacik <jbacik@fb.com>, netdev@vger.kernel.org,
        kernel-team@fb.com, ast@fb.com, jannh@google.com,
        davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:40690 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751512AbdBBUUt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 15:20:49 -0500
In-Reply-To: <1486054838-5072-1-git-send-email-jbacik@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/02/2017 06:00 PM, Josef Bacik wrote:
> These two tests are based on the work done for f23cc643f9ba.  The first test is
> just a basic one to make sure we don't allow AND'ing negative values, even if it
> would result in a valid index for the array.  The second is a cleaned up version
> of the original testcase provided by Jann Horn that resulted in the commit.
>
> Signed-off-by: Josef Bacik <jbacik@fb.com>

Thanks for following up!

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
