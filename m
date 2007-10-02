From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH][E1000E] some cleanups
Date: Tue, 02 Oct 2007 08:25:16 -0400
Message-ID: <1191327916.4353.10.camel@localhost>
References: <1191174077.6165.11.camel@localhost>
	 <46FFE809.8020504@intel.com> <1191178881.6165.40.camel@localhost>
	 <46FFF7AD.7090309@garzik.org> <1191180669.6165.50.camel@localhost>
	 <4700549A.70409@intel.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.230]:27367 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752588AbXJBMhY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 08:37:24 -0400
Received: by wr-out-0506.google.com with SMTP id 36so2128424wra
        for <netdev@vger.kernel.org>; Tue, 02 Oct 2007 05:37:23 -0700 (PDT)
In-Reply-To: <4700549A.70409@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2007-30-09 at 18:59 -0700, Kok, Auke wrote:

> the IDs are the only thing needed to enable all pci-e e1000 hardware.

I'll give it a whirl in the next few days. It failed as a module (with
e1000 compiled out), i will try to compile it in. I have access to the
hardware in quiet times - so it may be the weekend.

> by all means we need to have guys like you and Jeff test the commented IDs! I've
> been doing this myself and the e1000e driver goes to our labs for a period of
> testing from next week. Unfortunately they don't know how to break it that good as
> some of you guys ;)
> 
> I'll personally try to get an 82571EB tested on monday.

How did that go?

cheers,
jamal

