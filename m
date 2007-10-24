From: Florin Andrei <florin@andrei.myip.org>
Subject: Re: stateless 1:1 NAT
Date: Wed, 24 Oct 2007 12:12:22 -0700
Message-ID: <471F9916.1090404@andrei.myip.org>
References: <E1IhxQo-0004hF-00@gondolin.me.apana.org.au>
Reply-To: netdev@vger.kernel.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp120.sbc.mail.sp1.yahoo.com ([69.147.64.93]:40325 "HELO
	smtp120.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753410AbXJXTMZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Oct 2007 15:12:25 -0400
Received: from localhost (weiqi.home.local [127.0.0.1])
	by weiqi.home.local (Postfix) with ESMTP id 89D1F576EE4
	for <netdev@vger.kernel.org>; Wed, 24 Oct 2007 12:12:23 -0700 (PDT)
Received: from weiqi.home.local ([127.0.0.1])
	by localhost (andrei.myip.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id bB9O7ImRbIBE for <netdev@vger.kernel.org>;
	Wed, 24 Oct 2007 12:12:22 -0700 (PDT)
Received: from [192.168.2.8] (scout.vpn.local [192.168.2.8])
	by weiqi.home.local (Postfix) with ESMTP id 86079576ED4
	for <netdev@vger.kernel.org>; Wed, 24 Oct 2007 12:12:22 -0700 (PDT)
In-Reply-To: <E1IhxQo-0004hF-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> Florin Andrei <florin@andrei.myip.org> wrote:
>> I've heard that stateless 1:1 NAT will be possible with the upcoming 
>> 2.6.24 kernel.
>> I'd like to test that feature, but I'm not sure when it will actually be 
>> included. Will it be present in the release candidates for 2.6.24?
>> I just need a somewhat stable kernel tree to play with.
> 
> Yes it will be.

OK, if I download 2.6.24-rc1, will it have this feature already?
If not, when is it supposed to be included in the main kernel?

Thanks,

-- 
Florin Andrei

http://florin.myip.org/
