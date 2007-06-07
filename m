From: "kalash nainwal" <kalash.nainwal@gmail.com>
Subject: Re: extra layer below inet layer.
Date: Thu, 7 Jun 2007 16:03:09 +0530
Message-ID: <416aa1ad0706070333j2c5eb9day48331ffed65614f6@mail.gmail.com>
References: <2bd9ebfa0706062140vfddf3etfc8fd17749c9ad12@mail.gmail.com>
	 <416aa1ad0706070330i12fe211dn25cd2d174f3a7100@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Tej Parkash" <tejparkash.d@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.180]:15865 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751202AbXFGKdK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2007 06:33:10 -0400
Received: by ik-out-1112.google.com with SMTP id b32so390666ika
        for <netdev@vger.kernel.org>; Thu, 07 Jun 2007 03:33:09 -0700 (PDT)
In-Reply-To: <416aa1ad0706070330i12fe211dn25cd2d174f3a7100@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> >
> > so is it possible to unregister tcp and register my protocol dynamically.
>
> inet_unregister_protosw()/inet_register_protosw().

oops...can't unregister tcp (permanent protocol).

>
> -Kalash
>
