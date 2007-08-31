From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Subject: Re: Tc bug (kernel crash) more info
Date: Fri, 31 Aug 2007 14:59:55 +0400
Message-ID: <46D7F4AB.10009@bigtelecom.ru>
References: <20070830001632.ki4u5bx9sow40o4s@mail.himki.net> <20070830063110.GB1677@ff.dom.local> <20070830072718.GC1677@ff.dom.local> <46D68937.7030305@bigtelecom.ru> <20070830123751.GA2778@ff.dom.local> <46D7BD75.3080008@bigtelecom.ru> <20070831075909.GA1772@ff.dom.local> <46D7D072.5060508@bigtelecom.ru> <20070831090509.GC1772@ff.dom.local> <46D7E050.1030303@bigtelecom.ru> <20070831101733.GA3108@ff.dom.local> <46D7F273.5010401@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Jarek Poplawski <jarkao2@o2.pl>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:58451 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932445AbXHaK75 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2007 06:59:57 -0400
In-Reply-To: <46D7F273.5010401@bigtelecom.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

May be this bug eq "[PATCH] [NET_SCHED] sch_prio.c: remove duplicate 
call of tc_classify()"?

> I get kernel panic on 2.6.23-rc4-git2
> This is netconsole log!
...
