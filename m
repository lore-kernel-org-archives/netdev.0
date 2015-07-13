From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH 1/2] sctp: SCTP_SOCKOPT_PEELOFF return socket pointer
 for kernel users
Date: Mon, 13 Jul 2015 16:05:27 -0300
Message-ID: <55A40BF7.7060803@gmail.com>
References: <4dfd0ee7ac0aac0791812217e990e2ae7ff86955.1434645734.git.marcelo.leitner@gmail.com> <20150710.182114.1532697560595947999.davem@davemloft.net> <20150713103911.GA9631@hmsreliant.think-freely.org> <20150713.115912.324798425601463403.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vyasevich@gmail.com
To: David Miller <davem@davemloft.net>, nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f171.google.com ([209.85.220.171]:34734 "EHLO
	mail-qk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751866AbbGMTFe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2015 15:05:34 -0400
Received: by qkcl188 with SMTP id l188so77801588qkc.1
        for <netdev@vger.kernel.org>; Mon, 13 Jul 2015 12:05:33 -0700 (PDT)
In-Reply-To: <20150713.115912.324798425601463403.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13-07-2015 15:59, David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Mon, 13 Jul 2015 06:39:11 -0400
>
>> Initially Marcelo had created duplicate code paths, one to return an
>> fd, one to return a file struct.  If you would rather go in that
>> direction, I'm sure he can propose it again, but that seems less
>> correct to me than this solution.
>
> That's much better.

I'm not sure what you mean. Is the new option better or the 
history/description?

   Marcelo
