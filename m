From: "Beschorner Daniel" <Daniel.Beschorner@facton.com>
Subject: Re: Telnet closing delay
Date: Thu, 3 Apr 2008 14:04:49 +0200
Message-ID: <3C59DB883F7B0B4D8096010D45ACCD134F21C8@exch.facton.local>
References: <3C59DB883F7B0B4D8096010D45ACCD1323004D@exch.facton.local> <20070502091952.GA6060@2ka.mipt.ru> <3C59DB883F7B0B4D8096010D45ACCD134F21C0@exch.facton.local> <20080403104207.GA21848@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alpha.facton.com ([83.236.152.122]:36963 "EHLO alpha.facton.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755902AbYDCME6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2008 08:04:58 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20080403104207.GA21848@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> checking closed socket status is wrong. In recent kernels returned
error
> could be changed to something like -EINVAL, which is correctly handled

No worries, I just wanted to mention for the annals...
It's a rather old, but standard distro's, telnet server.

Daniel
