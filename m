From: kuznet@ms2.inr.ac.ru
Subject: Re: System crash in tcp_fragment()
Date: Tue, 21 May 2002 04:11:00 +0400 (MSD)
Sender: owner-netdev@oss.sgi.com
Message-ID: <200205210011.EAA04286@sex.inr.ac.ru>
References: <20020521015407.A1296@wotan.suse.de>
Mime-Version: 1.0
Cc: george@mvista.com, netdev@oss.sgi.com, linux-net@vger.kernel.org,
   davem@redhat.com, ak@muc.de, pekkas@netcore.fi
Return-path: <owner-netdev@oss.sgi.com>
To: ak@suse.de (Andi Kleen)
In-Reply-To: <20020521015407.A1296@wotan.suse.de> from "Andi Kleen" at May 21, 2 01:54:07 am
List-Id: netdev.vger.kernel.org

Hello!

> It's unfortunately the truth. Even in_interrupt() is buggy current 
> on SMP preemptive.

And why folks working on preemtive kernel do not repair this?
To all that I remember it is well known issue.

Alexey
