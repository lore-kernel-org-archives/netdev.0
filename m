From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [net-next 04/14] i40e: dump VF information in debugfs
Date: Fri, 21 Apr 2017 11:11:28 +0300
Message-ID: <CAJ3xEMgoUVFi7wmPL9GH0qV0Udkp8_oDveJTCyTwfA6aTzck1g@mail.gmail.com>
References: <BL2PR07MB2306DEC60F085B88BA230C3A8D1B0@BL2PR07MB2306.namprd07.prod.outlook.com>
 <20170420.115153.1510206006505486594.davem@davemloft.net> <BL2PR07MB23063D7F1341E629E9345F578D1B0@BL2PR07MB2306.namprd07.prod.outlook.com>
 <20170420.125841.799913763607507081.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Yuval.Mintz@cavium.com, Jiri Pirko <jiri@resnulli.us>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Mitch Williams <mitch.a.williams@intel.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        "nhorman@redhat.com" <nhorman@redhat.com>,
        "sassmann@redhat.com" <sassmann@redhat.com>,
        "jogreene@redhat.com" <jogreene@redhat.com>,
        Chad.Dupuis@cavium.com,
        Manish Rangankar <Manish.Rangankar@cavium.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f48.google.com ([209.85.218.48]:35444 "EHLO
        mail-oi0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1036405AbdDUIL3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 04:11:29 -0400
Received: by mail-oi0-f48.google.com with SMTP id j201so84038528oih.2
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 01:11:29 -0700 (PDT)
In-Reply-To: <20170420.125841.799913763607507081.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 20, 2017 at 7:58 PM, David Miller <davem@davemloft.net> wrote:
> From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
> Date: Thu, 20 Apr 2017 16:24:51 +0000
>
>> the HW pipeline itself can't be abstracted in this case.
>
> I've heard that argument before, and I'm glad Jiri didn't drink the
> koolaide and instead wrote dpipe.

donno re drinking but re writing s/jiri/arkadi/
