From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [Question]: iproute2 extension for supporting lightweight
 tunnel
Date: Thu, 15 Oct 2015 11:23:49 +0200
Message-ID: <20151015112349.44623b07@griffin>
References: <7DDE0CBD3BECA4418AF34146552BC32B08C3E1B9@SHSMSX104.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Liu, Mengke" <mengke.liu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41616 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751259AbbJOJXw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 05:23:52 -0400
In-Reply-To: <7DDE0CBD3BECA4418AF34146552BC32B08C3E1B9@SHSMSX104.ccr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 15 Oct 2015 06:26:30 +0000, Liu, Mengke wrote:
> I am trying to use the "lightweight tunnels" after building the Linux
> kernel from source with "Lightweight & flow based encapsulation"
> support. Can you tell me how to get iproute2 extension for supporting
> the following =C2=A0command in commit log(commit ID
> e69724f32e62502a6e686eae36b7aadfeea60dca)
>        "ip route add 40.1.1.1/32 encap vxlan id 10 dst 50.1.1.2 dev
> vxlan0"=20

This is not yet merged. AFAIK Thomas is going to post a patchset to add
this to iproute in a few days.

 Jiri

--=20
Jiri Benc
