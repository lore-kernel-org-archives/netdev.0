From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next 2/2] tools: psock_tpacket: verify that packet
 was received on lo before counting it
Date: Wed, 4 Jan 2017 11:27:11 -0500
Message-ID: <20170104162711.GG9641@oracle.com>
References: <cover.1483482971.git.sowmini.varadhan@oracle.com>
 <3451a2008d953f33d6576a35eaefecad883eaeb5.1483482971.git.sowmini.varadhan@oracle.com>
 <CAF=yD-+d-cgE1dxCcrfNZfgVk4_wjYMHHoQ=BN7bnJ-txbM-+Q@mail.gmail.com>
 <20170104144424.GD9641@oracle.com>
 <CAF=yD-KUw8M+RGnN2eXLVgv836F6mxd4+b0h=2CP6X7mv+ScWg@mail.gmail.com>
 <20170104151346.GE9641@oracle.com>
 <CAF=yD-+7Lj=boiJy6BPPJA-+-MrWqDd38-OFPcsWurUXkrwtzA@mail.gmail.com>
 <20170104161220.GF9641@oracle.com>
 <CAF=yD-L4W0fWXA7yq38vTjzbeia72ZdnHVQJj3o4SqpMTGp=xQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kselftest@vger.kernel.org,
        Network Development <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Willem de Bruijn <willemb@google.com>,
        David Miller <davem@davemloft.net>, shuah@kernel.org
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:50353 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S968643AbdADQ1c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 11:27:32 -0500
Content-Disposition: inline
In-Reply-To: <CAF=yD-L4W0fWXA7yq38vTjzbeia72ZdnHVQJj3o4SqpMTGp=xQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (01/04/17 11:24), Willem de Bruijn wrote:
> 
> Oh, good point. It may require some more refactoring. Feel free to
> leave it for me if you prefer.

actually it may not be so bad, let me do it, since I already have
a reliable way of reproducing this.. 

--Sowmini
