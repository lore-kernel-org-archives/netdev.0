From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: s2io: packet reordering with 2.6.25.4
Date: Thu, 26 Jun 2008 10:44:56 +0200
Message-ID: <48635708.8070100@gmail.com>
References: <4862DEA4.8020305@gmail.com> <48635341.8010609@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ram.vepa@neterion.com,
	santosh.rastapur@neterion.com, sivakumar.subramani@neterion.com,
	sreenivasa.honnur@neterion.com
To: Tom Quetchenbach <virtualphtn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:42416 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752147AbYFZIpY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2008 04:45:24 -0400
Received: by nf-out-0910.google.com with SMTP id d3so226310nfc.21
        for <netdev@vger.kernel.org>; Thu, 26 Jun 2008 01:45:20 -0700 (PDT)
In-Reply-To: <48635341.8010609@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote, On 06/26/2008 10:28 AM:
...

> Out of curiosity: is there affinity set for eths' irqs or they are
> balanced between cpus? (/proc/interrupts?)

...and maybe ifconfig on TX side?

Jarek P.
