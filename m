From: Stefan Wahren <info@lategoodbye.de>
Subject: Porting ethernet over spi driver
Date: Fri, 18 Apr 2014 11:17:18 +0200
Message-ID: <5350ED9E.6080103@lategoodbye.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.augenpunkt.de ([213.239.207.9]:41625 "EHLO
	www.augenpunkt.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751697AbaDRJhs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Apr 2014 05:37:48 -0400
Received: from erde.kosmos.lan (178-25-105-167-dynip.superkabel.de [178.25.105.167])
	by www.augenpunkt.de (Postfix) with ESMTP id CF414CED4F
	for <netdev@vger.kernel.org>; Fri, 18 Apr 2014 11:06:04 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

i'm trying to port a ethernet over spi driver to current mainline, which 
originally based on kernel 2.6.

Now i'm searching for some guidelines, checklists, common pitfalls or 
just hints about that.

Is there something about that, which is up to date?

Is there a list or something of legacy function, which shouldn't be used 
anymore?

Are there any new must have features?

Is there a good reference implementation for ethernet over spi?

Thanks in advance.

Kind regards
Stefan Wahren
