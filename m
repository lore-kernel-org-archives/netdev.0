From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP sequence number inference attack on Linux
Date: Fri, 21 Dec 2012 16:04:36 -0800
Message-ID: <1356134676.21834.8096.camel@edumazet-glaptop>
References: <CALvgte86miv450KnOcFRR-oEm_f=qRXarDfQkyU7T3OLqq816A@mail.gmail.com>
	 <1356114663.21834.7697.camel@edumazet-glaptop>
	 <CALvgte9x4LWV8rsquKzNoVcXM14xZjvyuTgpHr-ynZXfGtzzpw@mail.gmail.com>
	 <1356118052.21834.7793.camel@edumazet-glaptop>
	 <CALvgte9WJRR95B5WCTavF0w3Kvf+MksZtyY4OQ=ioAe71BasCw@mail.gmail.com>
	 <1356129948.21834.8002.camel@edumazet-glaptop>
	 <CALvgte-tpvyBF608MahqLc_JFZNzg2q1FpsUY72fDDicbdsBWA@mail.gmail.com>
	 <1356134481.21834.8090.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Zhiyun Qian <zhiyunq@umich.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f51.google.com ([209.85.210.51]:50005 "EHLO
	mail-da0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751371Ab2LVAEj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2012 19:04:39 -0500
Received: by mail-da0-f51.google.com with SMTP id i30so2325435dad.10
        for <netdev@vger.kernel.org>; Fri, 21 Dec 2012 16:04:38 -0800 (PST)
In-Reply-To: <1356134481.21834.8090.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-12-21 at 16:01 -0800, Eric Dumazet wrote:

> I began coding a serie of patches.

My goal is to make very small patches, to ease code review, and
eventually come to a state where we have more factorized code.
