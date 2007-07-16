From: Patrick McHardy <kaber@trash.net>
Subject: Re: IPSec freeze
Date: Mon, 16 Jul 2007 16:58:20 +0200
Message-ID: <469B878C.1020204@trash.net>
References: <469A3698.5020105@trash.net> <3C59DB883F7B0B4D8096010D45ACCD1323022E@exch.facton.local> <3C59DB883F7B0B4D8096010D45ACCD1323023A@exch.facton.local> <469B7001.3090604@trash.net> <3C59DB883F7B0B4D8096010D45ACCD1323023D@exch.facton.local> <469B7B99.6040402@trash.net> <3C59DB883F7B0B4D8096010D45ACCD13230240@exch.facton.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Beschorner Daniel <Daniel.Beschorner@facton.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52295 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757947AbXGPO6X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2007 10:58:23 -0400
In-Reply-To: <3C59DB883F7B0B4D8096010D45ACCD13230240@exch.facton.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Beschorner Daniel wrote:
>>I recreated the same setup here, but things work fine even with
>>different MTUs. Please try to narrow it down further or capture
>>some more information (serial console/netconsole,
>>CONFIG_DETECT_SOFTLOCKUP, ..).
> 
> 
> Did you turn on IPSec compression? 


No. Please send the policy you're using.
