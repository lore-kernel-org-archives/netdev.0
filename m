From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH] iproute2: hide devices starting with period by default
Date: Fri, 5 May 2017 08:47:13 +0200
Message-ID: <20170505084713.4321e69f@griffin>
References: <027775d1-ef98-deda-1f8d-bb058d1e4c2f@cumulusnetworks.com>
        <20170223163035.0a49f04d@xeon-e3>
        <13cec1c2-88f4-e61d-02ee-dc01ccee7281@cumulusnetworks.com>
        <20170223.221257.795227595252531962.davem@redhat.com>
        <0a8e1cf0-9f30-2356-5168-a97abb86d5c2@cumulusnetworks.com>
        <0635d3bb-0d8d-7ab6-fb53-4d84f979a023@6wind.com>
        <4bbb7a19-1b0b-8c9a-7e74-82ee146cf48c@gmail.com>
        <26442035-25fd-ff9a-2804-ed21ec6198cf@gmail.com>
        <01aa60dc-8bf2-3207-1abe-158100f52960@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>, nicolas.dichtel@6wind.com,
        David Miller <davem@redhat.com>, stephen@networkplumber.org,
        netdev@vger.kernel.org
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50506 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755507AbdEEGrR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 5 May 2017 02:47:17 -0400
In-Reply-To: <01aa60dc-8bf2-3207-1abe-158100f52960@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 4 May 2017 13:47:36 -0600, David Ahern wrote:
> On 5/4/17 1:10 PM, Florian Fainelli wrote:
> > On 05/04/2017 09:37 AM, David Ahern wrote:
> > Do you plan on submitting the LWT patch set at some point?
> 
> Definitely. Maybe I can find some time this weekend.

I suggest to change the name to "lwd" or so. "lwt" name is too similar
to the existing "lwtunnel" infrastructure and would be very confusing.

Thanks,

 Jiri
