From: David =?utf-8?B?R8OzbWV6?= <david@pleyades.net>
Subject: Re: IP1000 gigabit nic driver
Date: Fri, 28 Apr 2006 23:58:24 +0200
Message-ID: <20060428215824.GA2922@fargo>
References: <20060427142939.GA31473@fargo> <20060427185627.GA30871@electric-eye.fr.zoreil.com> <445144FF.4070703@cantab.net> <20060428075725.GA18957@fargo> <84144f020604280358ie9990c7h399f4a5588e575f8@mail.gmail.com> <20060428113755.GA7419@fargo> <Pine.LNX.4.58.0604281458110.19801@sbz-30.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Vrabel <dvrabel@cantab.net>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Linux-kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.hostinglmi.net ([213.194.149.12]:10174 "EHLO
	ns2.hostinglmi.net") by vger.kernel.org with ESMTP id S1751459AbWD1V6D
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Apr 2006 17:58:03 -0400
To: Pekka J Enberg <penberg@cs.Helsinki.FI>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0604281458110.19801@sbz-30.cs.Helsinki.FI>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Pekka,

On Apr 28 at 02:59:01, Pekka J Enberg wrote:
> Here are some suggestions for coding style cleanups:

Couple of questions,

>   - Use dev_{dbg,err,info,warn} for logging

Cannot, i need a "struct device" and most of the
there's only access to a "struct net_device". Am i
missing something?=20

>   - Use proper naming convention for things like Length and pPHYParam

What's the convention for these names?

Thanks,

--=20
David G=C3=B3mez                                      Jabber ID: davidg=
e@jabber.org
