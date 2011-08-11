From: Will de Bruijn <willemb@google.com>
Subject: Re: [PATCH v2] net: add Documentation/networking/scaling.txt
Date: Thu, 11 Aug 2011 10:26:23 -0400
Message-ID: <CA+FuTSfCp+Ju6YAGvPUzkLXiMFqV8XZV_SOueW5bwxeaeD1vng@mail.gmail.com>
References: <1312899648.5889.14.camel@gopher.nyc.corp.google.com> <4E418030.2010102@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: rdunlap@xenotime.net, linux-doc@vger.kernel.org,
	davem@davemloft.net, netdev@vger.kernel.org, therbert@google.com
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:58196 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753038Ab1HKO04 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2011 10:26:56 -0400
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id p7BEQsR1009325
	for <netdev@vger.kernel.org>; Thu, 11 Aug 2011 07:26:54 -0700
Received: from fxg7 (fxg7.prod.google.com [10.184.7.7])
	by wpaz13.hot.corp.google.com with ESMTP id p7BEQcsf001105
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 11 Aug 2011 07:26:53 -0700
Received: by fxg7 with SMTP id 7so2943253fxg.21
        for <netdev@vger.kernel.org>; Thu, 11 Aug 2011 07:26:53 -0700 (PDT)
In-Reply-To: <4E418030.2010102@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Any other worries I have a probably a matter of opinion or ignorance on my
> part.

I'll be happy to revise it once more. This version also lacks the
required one-line description in Documentation/networking/00-INDEX, so
I will have to resubmit, either way.

The 'suggested configuration' heuristics are certainly debatable, so
any questionable statements there can just be dropped. If the
technical description of the mechanisms is contentious, that would be
a more serious error.

  willem
