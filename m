From: kuznet@ms2.inr.ac.ru
Subject: Re: snd_cwnd drawn and quartered
Date: Tue, 14 Jan 2003 08:07:39 +0300 (MSK)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200301140507.IAA10741@sex.inr.ac.ru>
References: <Pine.LNX.4.33L0.0301131819320.31858-100000@orchestra.cs.caltech.edu>
Mime-Version: 1.0
Cc: wa@almesberger.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: chengjin@cs.caltech.edu (Cheng Jin)
In-Reply-To: <Pine.LNX.4.33L0.0301131819320.31858-100000@orchestra.cs.caltech.edu> from "Cheng Jin" at Jan 13, 3 06:19:58 pm
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> What would you like to see in the demo?  Just the straight output from my
> simulator?

Something which will allow to restore history to demonstrate
how it is possible to finish in recovery state with cwnd of 1
and lots of data in flight. I see that this is not impossible,
but simply cannot figure out when this madness happens.

Format does not matter. seq/(s)ack paires are good.

Alexey
