From: kuznet@ms2.inr.ac.ru
Subject: Re: SCTP path mtu support needs some ip layer support.
Date: Tue, 14 Jan 2003 00:25:44 +0300 (MSK)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200301132125.AAA09366@sex.inr.ac.ru>
References: <20030113210708.GA328@wotan.suse.de>
Mime-Version: 1.0
Cc: jgrimm2@us.ibm.com, davem@redhat.com, sri@us.ibm.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ak@suse.de (Andi Kleen)
In-Reply-To: <20030113210708.GA328@wotan.suse.de> from "Andi Kleen" at Jan 13, 3 10:07:08 pm
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> So in short clearing DF is near always a bug these days.

Exactly. And it is exactly why I said that this compromises all the pmtu
discvoery and why I would like people consulted SCTP designers before
doing this step. I cannot believe that new protocol was designed in this way.

Alexey
