From: Sven =?UTF-8?B?TcO8bGxlcg==?= <musv@gmx.de>
Subject: Re: Problems with mvneta
Date: Tue, 31 Oct 2017 15:23:22 +0100
Message-ID: <20171031152322.3e180c30@gmx.de>
References: <20171018223425.42ce7a74@gmx.de>
        <20171018225557.43837338@windsurf.home>
        <20171020002524.4b4cf122@gmx.de>
        <20171020090956.2b6cc34b@windsurf.home>
        <01d0cd47-20ef-bbad-cd93-749cc94d0d2f@cloudguard.ch>
        <20171023113024.7138970e@r84n0nz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        =?UTF-8?B?R3I=?= =?UTF-8?B?w6lnb3J5?= Clement
        <gregory.clement@free-electrons.com>,
        Antoine =?UTF-8?B?VMOpbmFydA==?=
        <antoine.tenart@free-electrons.com>, netdev@vger.kernel.org,
        Marcin Wojtas <mw@semihalf.com>
To: Andreas Tobler <andreas.tobler@cloudguard.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.20]:58098 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932115AbdJaOXZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Oct 2017 10:23:25 -0400
In-Reply-To: <20171023113024.7138970e@r84n0nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After quite a long time of trying to reproduce the issue without any success I got 3 network crashes today. And all errors occurred with a kernel including the patch: 

2a90f7e1d5d04e4f1060268e0b55a2c702bbd67a

At least according to Andreas' and my problems we can exclude the 6ad2 patch as the source of the errors. 

Thanks and regards
Sven
