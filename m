From: Pablo Cholaky <mrwaltercool@gmail.com>
Subject: Re: r8169 Wake on Lan
Date: Wed, 27 Nov 2013 17:32:36 -0300
Message-ID: <CAEv3EXG++vPHTT8iK4guonfgqFR4t+eHoZPn4n21cR5gJx3Bpg@mail.gmail.com>
References: <CAEv3EXFiUnfkBCiedjXUzc6MXBnP2vqNx4R3739642dGYazTwA@mail.gmail.com>
 <CAOWq=SwL=+-rwEqOYH8qUCObzL9sABA1f+6=pgnvQf1wNis3gw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Anupama Reddy <bn.anupama@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f54.google.com ([74.125.82.54]:45084 "EHLO
	mail-wg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751613Ab3K0Uc6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Nov 2013 15:32:58 -0500
Received: by mail-wg0-f54.google.com with SMTP id n12so6368228wgh.9
        for <netdev@vger.kernel.org>; Wed, 27 Nov 2013 12:32:56 -0800 (PST)
In-Reply-To: <CAOWq=SwL=+-rwEqOYH8qUCObzL9sABA1f+6=pgnvQf1wNis3gw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Anupama Reddy <bn.anupama@gmail.com>
>use the ethtool to disable the WOL option

Yes, I'm doing that, but a init script will not solve suspend to disk
or RAM auto-WOL problems, I need to "remember" it, I'm doing that
right now, but I don't think it's the best solution. Do you know
another option?
