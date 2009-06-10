From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Question regarding linux networking
Date: Wed, 10 Jun 2009 06:37:49 +0000
Message-ID: <20090610063749.GA2673@ff.dom.local>
References: <a05f5a000906090520y2b8b635epd1ef0f04c8d86fa7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, acme@redhat.com, nhorman@tuxdriver.com
To: sampath kumar <sampath.in@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f210.google.com ([209.85.219.210]:57549 "EHLO
	mail-ew0-f210.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756873AbZFJGhy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 02:37:54 -0400
Received: by ewy6 with SMTP id 6so670787ewy.37
        for <netdev@vger.kernel.org>; Tue, 09 Jun 2009 23:37:55 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <a05f5a000906090520y2b8b635epd1ef0f04c8d86fa7@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 09, 2009 at 05:50:09PM +0530, sampath kumar wrote:
> Hi All,

Hi,

I resend this message because it seems it wasn't accepted by netdev@.
(Try to use text/plain message format when sending here.)

Jarek P.

> 
> I'm trying to use/understand linux networking code. Say for example decnet,
> phonet etc, in order to register a device we need to send an RTM_NEWADDR msg
> to the kernel.
> 
> do I've to send it from kernel space or user space ? If I check the code of
> decnet or phonet, each have registered using rtnl_register an addr_doit func
> after reception of RTM_NEWADDR msg. how do i send this msg and from where ??
> 
> Can you pls help.
> 
> 
> B Sampath Kumar,
> ST-Ericsson,
> Bangalore - 38.
