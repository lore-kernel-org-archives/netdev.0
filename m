From: Debabrata Banerjee <dbavatar@gmail.com>
Subject: Re: [patch net] ipv6: do not create neighbor entries for local delivery
Date: Thu, 8 Aug 2013 15:19:25 -0400
Message-ID: <CAATkVEwRym1DGTD_oTNViAyDg+j2VXJZweGBfSbA3ny9sYM--A@mail.gmail.com>
References: <20130130082608.GA1604@minipsycho.orion>
	<CAATkVEzJgb+J-TAkTZCUbxLPj=b=wbOmsKbgNNimEfNaC8d0Aw@mail.gmail.com>
	<20130808190136.GE14001@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Debabrata Banerjee <dbavatar@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>, mleitner@redhat.com,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"jmorris@namei.org" <jmorris@namei.org>,
	"yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	"Banerjee, Debabrata" <dbanerje@akamai.com>,
	Joshua Hunt <johunt@akamai.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:37873 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966162Ab3HHTTZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Aug 2013 15:19:25 -0400
Received: by mail-qc0-f174.google.com with SMTP id c1so1766367qcz.19
        for <netdev@vger.kernel.org>; Thu, 08 Aug 2013 12:19:25 -0700 (PDT)
In-Reply-To: <20130808190136.GE14001@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 8, 2013 at 3:01 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
>
> Which kernel version are you using? Perhaps you miss another fix? It works for
> me. Also I cannot find this patch in net-next?
>

Just pulled and tried longterm 3.2.50, behavior is the same, broken.

-Debabrata
