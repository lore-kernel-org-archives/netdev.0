From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next 4/6] bpf: track if the bpf program was loaded
 with SYS_ADMIN capabilities
Date: Thu, 27 Apr 2017 16:56:45 +0200
Message-ID: <20170427165645.4115a5ce@griffin>
References: <CAADnVQ+GL6sYCff4eU4WXZYeZSi5BJ5amy6NQjuZk2=OjuM5+g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>,
        Aaron Conole <aconole@bytheb.org>,
        Daniel Borkmann <daniel@iogearbox.net>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60704 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755239AbdD0O4t (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Apr 2017 10:56:49 -0400
In-Reply-To: <CAADnVQ+GL6sYCff4eU4WXZYeZSi5BJ5amy6NQjuZk2=OjuM5+g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 27 Apr 2017 07:49:29 -0700, Alexei Starovoitov wrote:
> there are bunch of other things that influence verifier.
> should we add all of them ?

Sure, why not? It's always good to be able to see the complete input
conditions while debugging.

 Jiri
