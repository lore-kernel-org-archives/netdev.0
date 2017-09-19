From: Shuah Khan <shuah@kernel.org>
Subject: Re: [PATCH 1/3][v2] selftest: add a reuseaddr test
Date: Tue, 19 Sep 2017 15:30:41 -0600
Message-ID: <9e65d527-a826-815a-d0d8-9ce27cc7c66a@kernel.org>
References: <1505829088-1823-1-git-send-email-jbacik@fb.com>
Reply-To: shuah@kernel.org
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Josef Bacik <jbacik@fb.com>, Shuah Khan <shuahkh@osg.samsung.com>,
        Shuah Khan <shuah@kernel.org>
To: josef@toxicpanda.com, davem@davemloft.net, netdev@vger.kernel.org,
        linux-kselftest@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.easymail.ca ([64.68.200.34]:46631 "EHLO
        mailout.easymail.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751309AbdISVax (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 17:30:53 -0400
In-Reply-To: <1505829088-1823-1-git-send-email-jbacik@fb.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/19/2017 07:51 AM, josef@toxicpanda.com wrote:
> From: Josef Bacik <jbacik@fb.com>
> 
> This is to test for a regression introduced by
> 
> b9470c27607b ("inet: kill smallest_size and smallest_port")
> 
> which introduced a problem with reuseaddr and bind conflicts.
> 
> Signed-off-by: Josef Bacik <jbacik@fb.com>

I usually don't sent new tests however, since it is a test for a
regression, applied to linux-kselftest fixes for 4.14-rc2

thanks,
-- Shuah
