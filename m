From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [RHEL6.8 net PATCH] ipv4/icmp: redirect messages can use the
 ingress daddr as source
Date: Fri, 09 Oct 2015 12:16:37 +0200
Message-ID: <1444385797.4614.1.camel@dhcp-176-88.mxp.redhat.com>
References: <d10d2ec1cdf0334e9951b819051d4a127e103091.1444383578.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jonathan Corbet <corbet@lwn.net>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56537 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757432AbbJIKQm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Oct 2015 06:16:42 -0400
In-Reply-To: <d10d2ec1cdf0334e9951b819051d4a127e103091.1444383578.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I'm sorry, I messed with the subject tag. I'm going to resubmit.

Sorry for the noise,

Paolo
