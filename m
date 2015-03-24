From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH for kernel 3.4.x 0/1] net: neighbour: Add mcast_resolicit
 to configure the number of multicast resolicitations in PROBE state
Date: Wed, 25 Mar 2015 08:06:02 +0900
Message-ID: <5511EDDA.5080105@miraclelinux.com>
References: <1427190355-1216-1-git-send-email-Yanjun.Zhu@windriver.com>	<55114543.2080709@miraclelinux.com> <20150324.115938.688597808655372422.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com, Yanjun.Zhu@windriver.com,
	lizefan@huawei.com, netdev@vger.kernel.org,
	ulf.samuelsson@ericsson.com, yoshfuji@linux-ipv6.org,
	Alexandre.Dietsch@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og125.obsmtp.com ([64.18.2.28]:47412 "HELO
	exprod7og125.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751928AbbCXXGG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 19:06:06 -0400
Received: by mail-pd0-f178.google.com with SMTP id c3so7911980pdn.0
        for <netdev@vger.kernel.org>; Tue, 24 Mar 2015 16:06:06 -0700 (PDT)
In-Reply-To: <20150324.115938.688597808655372422.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
> Date: Tue, 24 Mar 2015 20:06:43 +0900
> 
>> Hmm, it needs additional knob to change this 10+-year-old
>> behavior.  I am not for backporting this to old stable
>> kernels unless all stable kernels supports this knob as
>> well.
> 
> It is not appropriate for -stable at all.
> 

I thought some people might say that it was a long-standing
bug, but I totally agree with you, Dave.

--yoshfuji
