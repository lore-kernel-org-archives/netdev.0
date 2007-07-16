From: "Beschorner Daniel" <Daniel.Beschorner@facton.com>
Subject: Re: IPSec freeze
Date: Mon, 16 Jul 2007 16:17:01 +0200
Message-ID: <3C59DB883F7B0B4D8096010D45ACCD13230240@exch.facton.local>
References: <469A3698.5020105@trash.net> <3C59DB883F7B0B4D8096010D45ACCD1323022E@exch.facton.local> <3C59DB883F7B0B4D8096010D45ACCD1323023A@exch.facton.local> <469B7001.3090604@trash.net> <3C59DB883F7B0B4D8096010D45ACCD1323023D@exch.facton.local> <469B7B99.6040402@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alpha.facton.com ([83.236.152.122]:44963 "EHLO alpha.facton.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759113AbXGPORI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2007 10:17:08 -0400
Content-class: urn:content-classes:message
In-reply-to: <469B7B99.6040402@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> I recreated the same setup here, but things work fine even with
> different MTUs. Please try to narrow it down further or capture
> some more information (serial console/netconsole,
> CONFIG_DETECT_SOFTLOCKUP, ..).

Did you turn on IPSec compression? 
