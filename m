From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: HHF support in =?UTF-8?Q?iproute=32=3F?=
Date: Sat, 12 Apr 2014 07:11:13 +0300
Message-ID: <4420ec641916f42ac8bb9becc634a8cf@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:41726 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750816AbaDLER6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Apr 2014 00:17:58 -0400
Received: from hosting.visp.net.lb (localhost [127.0.0.1])
	by hosting.visp.net.lb (Postfix) with ESMTP id F00CC488CBF
	for <netdev@vger.kernel.org>; Sat, 12 Apr 2014 07:11:13 +0300 (EEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

I just tried recently last iproute2 (git and release) and noticed in 
iproute-3.14.0 it is still missing HHF support, while i see it is 
accepted in git
(http://marc.info/?l=linux-netdev&m=138933793006411&w=2)
Is there any problem with this scheduling discipline?

Thanks!
