From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Subject: Re: high latency with TCP connections
Date: Fri, 1 Sep 2006 09:08:34 +1200
Message-ID: <5640c7e00608311408l1418321tadd69726d252ca5a@mail.gmail.com>
References: <20060830100734.GA22235@isil.ipib.msu.ru>
	 <20060830102727.11e11453@localhost.localdomain>
	 <20060830.143955.55510936.davem@davemloft.net>
	 <fa1e4ce70608311122n6555b7c3n1ecec9ed3adc46c2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, shemminger@osdl.org,
	alex@sectorb.msk.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-f131.google.com ([64.233.182.131]:27024 "EHLO
	nf-out-f131.google.com") by vger.kernel.org with ESMTP
	id S1751249AbWHaVIg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Aug 2006 17:08:36 -0400
Received: by nf-out-f131.google.com with SMTP id k65so31814nfa
        for <netdev@vger.kernel.org>; Thu, 31 Aug 2006 14:08:34 -0700 (PDT)
To: "Kelly Burkhart" <kelly.burkhart@gmail.com>
In-Reply-To: <fa1e4ce70608311122n6555b7c3n1ecec9ed3adc46c2@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> The word performance in this list seems to always mean 'throughput'.
> It seems though that there could be some knob to tweak for those of us
> who don't care so much about throughput but care a great deal about
> latency.
>
SCTP has been mentioned. There is also DCCP - http://www.read.cs.ucla.edu/dccp/

-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
