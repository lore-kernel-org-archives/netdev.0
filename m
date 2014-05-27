From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next 1/2] net: filter: test fill/spill of all M[]
 regs
Date: Tue, 27 May 2014 18:57:46 +0200
Message-ID: <5384C40A.7050203@redhat.com>
References: <1401128255-6545-1-git-send-email-dborkman@redhat.com> <1401128255-6545-2-git-send-email-dborkman@redhat.com> <CAMEtUuyP+F5SxBnaT7a3LgAwcp5MG6knWEsdt1-xdq2pk2gWxQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60183 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751927AbaE0Q5v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 May 2014 12:57:51 -0400
In-Reply-To: <CAMEtUuyP+F5SxBnaT7a3LgAwcp5MG6knWEsdt1-xdq2pk2gWxQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/27/2014 08:02 AM, Alexei Starovoitov wrote:
...
> store and immediate load from the same slot won't catch slot overlap,
> but that would be a job for another test.

Have a test in my queue. ;)
