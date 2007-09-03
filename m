From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Subject: Re: Tc bug (kernel crash) more info
Date: Mon, 03 Sep 2007 12:31:39 +0400
Message-ID: <46DBC66B.1000003@bigtelecom.ru>
References: <46D7BD75.3080008@bigtelecom.ru> <20070831075909.GA1772@ff.dom.local> <46D7D072.5060508@bigtelecom.ru> <20070831090509.GC1772@ff.dom.local> <46D7E050.1030303@bigtelecom.ru> <20070831101733.GA3108@ff.dom.local> <46D7F1FF.1000101@bigtelecom.ru> <20070831125917.GC3108@ff.dom.local> <46D8265B.6000405@bigtelecom.ru> <46D82AEC.5010404@bigtelecom.ru> <20070903073059.GA1899@ff.dom.local> <46DBC059.5020405@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Jarek Poplawski <jarkao2@o2.pl>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:44919 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750947AbXICIbm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Sep 2007 04:31:42 -0400
In-Reply-To: <46DBC059.5020405@bigtelecom.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

May you also see that i need change to fix this:

qdisc handle can >= 10 000

i have more then 10 000 qdiscs =(


