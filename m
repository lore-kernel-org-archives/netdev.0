From: Berend De Schouwer <berend.de.schouwer@gmail.com>
Subject: Re: tg3 pxe weirdness
Date: Fri, 22 Sep 2017 15:20:40 +0200
Message-ID: <1506086440.18177.88.camel@gmail.com>
References: <CAMet4B4Jdgjs42KAWQ4HJr1t_Grn1_+Hv8sipeLb_tvZ_SFrMw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Siva Reddy Kallam <siva.kallam@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35746 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752068AbdIVNUq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2017 09:20:46 -0400
Received: by mail-wm0-f67.google.com with SMTP id e64so1288450wmi.2
        for <netdev@vger.kernel.org>; Fri, 22 Sep 2017 06:20:45 -0700 (PDT)
In-Reply-To: <CAMet4B4Jdgjs42KAWQ4HJr1t_Grn1_+Hv8sipeLb_tvZ_SFrMw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-09-22 at 11:51 +0530, Siva Reddy Kallam wrote:
> On Thu, Sep 21, 2017 at 7:53 PM, Berend De Schouwer
> <berend.de.schouwer@gmail.com> wrote:
> > Hi,
> > 
> > I've got a machine with a Broadcom bcm5762c, using the tg3 driver,
> > that
> > fails to receive network packets under some very specific
> > conditions.
> > 
> > 
> > Berend
> 
> Can you please share below details?
> 1) Model and Manufacturer of the system
> 2) Linux distro/kernel used?

3.10.107 behaves like CentOS' kernel.
