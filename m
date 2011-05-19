From: Tom Herbert <therbert@google.com>
Subject: Re: GRE RPS patch set
Date: Thu, 19 May 2011 15:50:41 -0700
Message-ID: <BANLkTin1xx5htFaoa4Nn+sG05pGF_e1n1A@mail.gmail.com>
References: <20110519.171442.1015392662738718919.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:17629 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754826Ab1ESWvH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 18:51:07 -0400
Received: from hpaq7.eem.corp.google.com (hpaq7.eem.corp.google.com [172.25.149.7])
	by smtp-out.google.com with ESMTP id p4JMou6A003334
	for <netdev@vger.kernel.org>; Thu, 19 May 2011 15:51:06 -0700
Received: from pxi10 (pxi10.prod.google.com [10.243.27.10])
	by hpaq7.eem.corp.google.com with ESMTP id p4JMof4D023217
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 19 May 2011 15:50:45 -0700
Received: by pxi10 with SMTP id 10so2313414pxi.22
        for <netdev@vger.kernel.org>; Thu, 19 May 2011 15:50:41 -0700 (PDT)
In-Reply-To: <20110519.171442.1015392662738718919.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Updating all call sites of a function when you change it's arguments
> isn't rocket science. :-)
>

So it would seem... thanks for pointing that out.
