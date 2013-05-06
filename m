From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: PATCH iproute2] catch iptables interface changes
Date: Mon, 6 May 2013 08:09:58 -0700
Message-ID: <20130506080958.79562cfe@nehalam.linuxnetplumber.net>
References: <517D35D6.8090606@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jan Engelhardt <jengelh@inai.de>,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:59001 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753652Ab3EFPKC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 May 2013 11:10:02 -0400
Received: by mail-pd0-f181.google.com with SMTP id p11so2059012pdj.12
        for <netdev@vger.kernel.org>; Mon, 06 May 2013 08:10:02 -0700 (PDT)
In-Reply-To: <517D35D6.8090606@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 28 Apr 2013 10:44:38 -0400
Jamal Hadi Salim <jhs@mojatatu.com> wrote:

> 
> Thanks to Jan for this suggestion.
> Hopefully this would ease some of the pain.
> 
> cheers,
> jamal

Any feedback from the netfilter team? Is this right?
I would prefer to change wording of the error to something more professional.
It may trigger 15 years from now and everybody around forgot what that meant.
