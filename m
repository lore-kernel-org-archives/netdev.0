From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH] iproute2: hide devices starting with period by default
Date: Thu, 4 May 2017 17:15:33 +0200
Message-ID: <0635d3bb-0d8d-7ab6-fb53-4d84f979a023@6wind.com>
References: <027775d1-ef98-deda-1f8d-bb058d1e4c2f@cumulusnetworks.com>
 <20170223163035.0a49f04d@xeon-e3>
 <13cec1c2-88f4-e61d-02ee-dc01ccee7281@cumulusnetworks.com>
 <20170223.221257.795227595252531962.davem@redhat.com>
 <0a8e1cf0-9f30-2356-5168-a97abb86d5c2@cumulusnetworks.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem@redhat.com>, stephen@networkplumber.org,
        netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:37881 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754745AbdEDPP1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 11:15:27 -0400
Received: by mail-wm0-f48.google.com with SMTP id m123so19357765wma.0
        for <netdev@vger.kernel.org>; Thu, 04 May 2017 08:15:26 -0700 (PDT)
In-Reply-To: <0a8e1cf0-9f30-2356-5168-a97abb86d5c2@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 24/02/2017 à 16:52, David Ahern a écrit :
> On 2/23/17 8:12 PM, David Miller wrote:
>> This really need to be a fundamental facility, so that it transparently
>> works for NetworkManager, router daemons, everything.  Not just iproute2
>> and "ls".
> 
> I'll rebase my patch and send out as RFC.
> 
David, did you finally send those patches?


Thank you,
Nicolas
