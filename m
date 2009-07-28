From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [question] bridged tunnel
Date: Tue, 28 Jul 2009 10:18:18 +0200
Message-ID: <20090728081818.GA6522@psychotron.englab.brq.redhat.com>
References: <20090728075928.GB3633@psychotron.englab.brq.redhat.com> <200907281111.16433.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: =?iso-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:34106 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751992AbZG1ISZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jul 2009 04:18:25 -0400
Content-Disposition: inline
In-Reply-To: <200907281111.16433.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Jul 28, 2009 at 10:11:15AM CEST, remi.denis-courmont@nokia.com wro=
te:
>On Tuesday 28 July 2009 10:59:29 ext Jiri Pirko wrote:
>> Hello all.
>>
>> Imagine following net scheme:
>>
>> LAN1 --- ROUTER A --- ROUTER B --- LAN2
>>
>> I would like to have LAN1 and LAN2 bridged together.
>
>Then just put both interfaces to LAN1 and LAN2 in the same bridge... W=
hy do=20
>you want to bring TAP here?!

Well generally there could be anything (e.g. internet) in between ROUTE=
R A and
B. That's why.

>
>--=20
>R=E9mi Denis-Courmont
>Nokia Devices R&D, Maemo Software, Helsinki
>
