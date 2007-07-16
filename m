From: "Beschorner Daniel" <Daniel.Beschorner@facton.com>
Subject: Re: IPSec freeze
Date: Mon, 16 Jul 2007 17:36:17 +0200
Message-ID: <3C59DB883F7B0B4D8096010D45ACCD13230242@exch.facton.local>
References: <469A3698.5020105@trash.net> <3C59DB883F7B0B4D8096010D45ACCD1323022E@exch.facton.local> <3C59DB883F7B0B4D8096010D45ACCD1323023A@exch.facton.local> <469B7001.3090604@trash.net> <3C59DB883F7B0B4D8096010D45ACCD1323023D@exch.facton.local> <469B7B99.6040402@trash.net> <3C59DB883F7B0B4D8096010D45ACCD13230240@exch.facton.local> <469B878C.1020204@trash.net> <469B8C47.3030306@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alpha.facton.com ([83.236.152.122]:55973 "EHLO alpha.facton.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755463AbXGPPgX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2007 11:36:23 -0400
Content-class: urn:content-classes:message
In-reply-to: <469B8C47.3030306@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> >>Did you turn on IPSec compression? 
> > 
> > 
> > 
> > No. Please send the policy you're using.
> 
> 
> I managed to reproduce a crash with ipcomp, will try to fix it later.

Yes, I can confirm this.
After disabling IPComp the crashes went away.

Thank you
Daniel
