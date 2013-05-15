From: =?ISO-8859-1?Q?Holger_Hoffst=E4tte?=
	<holger.hoffstaette@googlemail.com>
Subject: Re: r8169 driver cause ssh failure
Date: Wed, 15 May 2013 10:16:18 +0200
Message-ID: <51934452.5040600@googlemail.com>
References: <CA+6wjbxdbTDXmO984sM1CHFT+PJJdvS=+YmwM2iu-10Ws4WouA@mail.gmail.com> <5190841E.9090503@canonical.com> <20130513063332.GA16374@electric-eye.fr.zoreil.com> <pan.2013.05.13.13.24.46.794122@googlemail.com> <20130514225422.GA32242@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mho-02-ewr.mailhop.org ([204.13.248.72]:61895 "EHLO
	mho-02-ewr.mailhop.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757021Ab3EOIQX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 May 2013 04:16:23 -0400
In-Reply-To: <20130514225422.GA32242@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15.05.2013 00:54, Francois Romieu wrote:
> Could you check if the patch below helps ?

Seems to work fine! I have turned tx offloading back on and everything
works again, just like before the regression.

Thanks!

-h
